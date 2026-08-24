import St from 'gi://St';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';

/**
 * @param {object} _extension - The TopbarExtension instance
 * @returns {object} The panel indicator
 */
export function setup(_extension) {
  const indicator = new PanelMenu.Button(0.0, 'Topbar', false);

  const icon = new St.Icon({
    icon_name: 'dialog-information-symbolic',
    style_class: 'system-status-icon',
  });
  indicator.add_child(icon);

  Main.panel.addToStatusArea('topbar', indicator);

  return indicator;
}
