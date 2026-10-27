// Applies the layout mutter saved in ~/.config/monitors.xml for the monitors
// that are connected right now. Kept free of gnome-shell imports so it can be
// exercised from a plain gjs process as well.
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';

const BUS_NAME = 'org.gnome.Mutter.DisplayConfig';
const OBJECT_PATH = '/org/gnome/Mutter/DisplayConfig';
const METHOD_TEMPORARY = 1;
const ROTATIONS = ['normal', 'left', 'upside_down', 'right'];

function callDisplayConfig(method, parameters, replyType) {
    return new Promise((resolve, reject) => {
        Gio.DBus.session.call(
            BUS_NAME, OBJECT_PATH, BUS_NAME, method, parameters,
            replyType ? new GLib.VariantType(replyType) : null,
            Gio.DBusCallFlags.NONE, -1, null,
            (connection, result) => {
                try {
                    resolve(connection.call_finish(result));
                } catch (e) {
                    reject(e);
                }
            });
    });
}

function loadFile(path) {
    return new Promise((resolve, reject) => {
        Gio.File.new_for_path(path).load_contents_async(null, (file, result) => {
            try {
                const [, contents] = file.load_contents_finish(result);
                resolve(new TextDecoder().decode(contents));
            } catch (e) {
                reject(e);
            }
        });
    });
}

function decodeEntities(text) {
    return text
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>')
        .replace(/&quot;/g, '"')
        .replace(/&apos;/g, "'")
        .replace(/&amp;/g, '&');
}

function elements(xml, name) {
    const pattern = new RegExp(`<${name}>([\\s\\S]*?)</${name}>`, 'g');
    return [...xml.matchAll(pattern)].map(match => match[1]);
}

function element(xml, name) {
    const [first] = elements(xml, name);
    return first === undefined ? null : decodeEntities(first.trim());
}

function parseSpec(xml) {
    return ['connector', 'vendor', 'product', 'serial'].map(field => element(xml, field) ?? '');
}

function parseTransform(xml) {
    const transform = element(xml, 'transform');
    if (transform === null)
        return 0;

    const rotation = ROTATIONS.indexOf(element(transform, 'rotation') ?? 'normal');
    if (rotation < 0)
        throw new Error(`Unknown rotation in ${transform}`);

    return rotation + (element(transform, 'flipped') === 'yes' ? 4 : 0);
}

function parseConfigurations(xml) {
    return elements(xml, 'configuration').map(configuration => {
        const logicalMonitors = elements(configuration, 'logicalmonitor').map(logical => ({
            x: parseInt(element(logical, 'x'), 10),
            y: parseInt(element(logical, 'y'), 10),
            scale: parseFloat(element(logical, 'scale') ?? '1'),
            transform: parseTransform(logical),
            primary: element(logical, 'primary') === 'yes',
            monitors: elements(logical, 'monitor').map(monitor => {
                const mode = element(monitor, 'mode');
                return {
                    spec: parseSpec(element(monitor, 'monitorspec')),
                    width: parseInt(element(mode, 'width'), 10),
                    height: parseInt(element(mode, 'height'), 10),
                    rate: parseFloat(element(mode, 'rate')),
                };
            }),
        }));
        const disabled = elements(configuration, 'disabled')
            .flatMap(block => elements(block, 'monitorspec').map(parseSpec));

        return {
            layoutMode: element(configuration, 'layoutmode') === 'physical' ? 2 : 1,
            logicalMonitors,
            specs: [
                ...logicalMonitors.flatMap(logical => logical.monitors.map(monitor => monitor.spec)),
                ...disabled,
            ],
        };
    });
}

const specKey = spec => spec.join('\u0000');

function findMode(connectedMonitor, monitor) {
    const mode = connectedMonitor.modes.find(([, width, height, refresh]) =>
        width === monitor.width && height === monitor.height &&
        Math.abs(refresh - monitor.rate) < 0.001);
    if (!mode)
        throw new Error(`No ${monitor.width}x${monitor.height}@${monitor.rate} mode on ${connectedMonitor.connector}`);

    return mode[0];
}

function joinedLayout(configurations, connected) {
    const configuration = configurations.find(candidate =>
        candidate.specs.length === connected.size &&
        candidate.specs.every(spec => connected.has(specKey(spec))));
    if (!configuration)
        return null;

    return configuration.logicalMonitors.map(logical => [
        logical.x, logical.y, logical.scale, logical.transform, logical.primary,
        logical.monitors.map(monitor => {
            const connectedMonitor = connected.get(specKey(monitor.spec));
            return [connectedMonitor.connector, findMode(connectedMonitor, monitor), {}];
        }),
    ]);
}

// A single monitor keeps the mode, scale and rotation it has in any stored
// layout; mutter's own "Built-in Only" would fall back to its default scale.
function singleLayout(configurations, connectedMonitor) {
    for (const configuration of configurations) {
        for (const logical of configuration.logicalMonitors) {
            const monitor = logical.monitors.find(candidate =>
                specKey(candidate.spec) === connectedMonitor.key);
            if (monitor) {
                return [[0, 0, logical.scale, logical.transform, true,
                    [[connectedMonitor.connector, findMode(connectedMonitor, monitor), {}]]]];
            }
        }
    }
    return null;
}

/**
 * Applies the stored layout for the connected monitors.
 *
 * @param {'joined'|'builtin'|'external'} target which monitors to enable
 * @returns {Promise<boolean>} false when monitors.xml has no usable layout
 */
export async function applyStoredLayout(target) {
    const reply = await callDisplayConfig('GetCurrentState', null,
        '(ua((ssss)a(siiddada{sv})a{sv})a(iiduba(ssss)a{sv})a{sv})');
    const [serial, monitors, , properties] = reply.recursiveUnpack();
    const layoutMode = properties['layout-mode'] ?? 1;

    const connected = new Map(monitors.map(([spec, modes, monitorProperties]) => [specKey(spec), {
        key: specKey(spec),
        connector: spec[0],
        modes,
        builtin: monitorProperties['is-builtin'] === true,
    }]));
    const path = GLib.build_filenamev([GLib.get_user_config_dir(), 'monitors.xml']);
    const configurations = parseConfigurations(await loadFile(path))
        .filter(configuration => configuration.layoutMode === layoutMode);

    let logicalMonitors;
    if (target === 'joined') {
        logicalMonitors = joinedLayout(configurations, connected);
    } else {
        const wantBuiltin = target === 'builtin';
        const candidates = [...connected.values()].filter(monitor => monitor.builtin === wantBuiltin);
        logicalMonitors = candidates.length === 1 ? singleLayout(configurations, candidates[0]) : null;
    }
    if (!logicalMonitors)
        return false;

    await callDisplayConfig('ApplyMonitorsConfig',
        new GLib.Variant('(uua(iiduba(ssa{sv}))a{sv})',
            [serial, METHOD_TEMPORARY, logicalMonitors, {}]),
        null);
    return true;
}
