// GNOME's Super+P "Join Displays" builds a fresh linear layout that starts at
// the current primary monitor, so after "External Only" the external monitor
// lands left of the laptop. This keeps the stock popup but makes "Join
// Displays" restore the layout saved in monitors.xml.
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

const StoredLayoutSwitchMonitorPopup = GObject.registerClass(
class StoredLayoutSwitchMonitorPopup extends SwitchMonitorPopup {
    _initialSelection() {
        // Configs applied over D-Bus report UNKNOWN; with several monitors
        // showing, that is the joined layout this popup restored.
        let current = global.backend.get_monitor_manager().get_switch_config();
        if (current === Meta.MonitorSwitchConfigType.UNKNOWN && Main.layoutManager.monitors.length > 1)
            current = Meta.MonitorSwitchConfigType.ALL_LINEAR;

        this._select((current + 1) % this._items.length);
    }

    _finish(timestamp) {
        const {configType} = this._items[this._selectedIndex];
        if (configType !== Meta.MonitorSwitchConfigType.ALL_LINEAR) {
            super._finish(timestamp);
            return;
        }

        SwitcherPopup.SwitcherPopup.prototype._finish.call(this, timestamp);

        const monitorManager = global.backend.get_monitor_manager();
        applyStoredLayout().then(applied => {
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
