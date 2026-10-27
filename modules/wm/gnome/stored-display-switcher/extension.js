// GNOME's Super+P builds fresh layouts instead of reusing monitors.xml: "Join
// Displays" starts at the current primary monitor, so after "External Only"
// the external monitor lands left of the laptop, and the single-display
// modes fall back to mutter's default scale (100% instead of 125% on the
// laptop panel). This keeps the stock popup but makes those three modes
// apply the layout, modes and scales saved in monitors.xml.
import GObject from 'gi://GObject';
import Meta from 'gi://Meta';
import Shell from 'gi://Shell';

import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as SwitcherPopup from 'resource:///org/gnome/shell/ui/switcherPopup.js';
import {SwitchMonitorPopup} from 'resource:///org/gnome/shell/ui/switchMonitor.js';

import {applyStoredLayout} from './storedLayout.js';

const KEYBINDING = 'switch-monitor';
const ACTION_MODES = Shell.ActionMode.NORMAL | Shell.ActionMode.OVERVIEW;

const STORED_TARGETS = new Map([
    [Meta.MonitorSwitchConfigType.ALL_LINEAR, 'joined'],
    [Meta.MonitorSwitchConfigType.BUILTIN, 'builtin'],
    [Meta.MonitorSwitchConfigType.EXTERNAL, 'external'],
]);

// Configs applied over D-Bus report UNKNOWN; derive which mode is showing.
function currentSwitchConfig() {
    const monitorManager = global.backend.get_monitor_manager();
    const current = monitorManager.get_switch_config();
    if (current !== Meta.MonitorSwitchConfigType.UNKNOWN)
        return current;
    if (Main.layoutManager.monitors.length > 1)
        return Meta.MonitorSwitchConfigType.ALL_LINEAR;
    return monitorManager.get_is_builtin_display_on()
        ? Meta.MonitorSwitchConfigType.BUILTIN
        : Meta.MonitorSwitchConfigType.EXTERNAL;
}

const StoredLayoutSwitchMonitorPopup = GObject.registerClass(
class StoredLayoutSwitchMonitorPopup extends SwitchMonitorPopup {
    _initialSelection() {
        this._select((currentSwitchConfig() + 1) % this._items.length);
    }

    _finish(timestamp) {
        const {configType} = this._items[this._selectedIndex];
        const target = STORED_TARGETS.get(configType);
        if (!target) {
            super._finish(timestamp);
            return;
        }

        SwitcherPopup.SwitcherPopup.prototype._finish.call(this, timestamp);

        const monitorManager = global.backend.get_monitor_manager();
        applyStoredLayout(target).then(applied => {
            if (!applied)
                monitorManager.switch_config(configType);
        }).catch(e => {
            logError(e, 'Failed to apply the stored monitor layout');
            monitorManager.switch_config(configType);
        });
    }
});

export default class StoredDisplaySwitcherExtension extends Extension {
    enable() {
        Main.wm.setCustomKeybindingHandler(KEYBINDING, ACTION_MODES,
            (_display, _window, _event, binding) => {
                const popup = new StoredLayoutSwitchMonitorPopup();
                if (!popup.show(binding.is_reversed(), binding.get_name(), binding.get_mask()))
                    popup.destroy();
            });
    }

    disable() {
        Main.wm.setCustomKeybindingHandler(KEYBINDING, ACTION_MODES,
            Main.wm._startSwitcher.bind(Main.wm));
    }
}
