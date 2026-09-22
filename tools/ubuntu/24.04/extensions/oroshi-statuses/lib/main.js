import Gio from 'gi://Gio';
import St from 'gi://St';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';

const INDICATOR_ID = 'oroshi-statuses';

class OroshiStatuses {
  /**
   * @param {object} extension - The OroshiStatusesExtension instance
   * @param _extension
   */
  constructor(_extension) {
    this._libPath = Gio.File.new_for_uri(import.meta.url)
      .get_parent()
      .get_path();
    this._originalRegisterMethod = null;
    this._watcherPrototype = null;
    this._button = null;
    this._icon = null;

    this._showIcon();
    this._patchWatcher();
  }

  /** Tear down all resources and remove the panel indicator */
  destroy() {
    this._unpatchWatcher();
    this._destroyButton();
  }

  /** Show the oroshi "x" icon in the top bar */
  _showIcon() {
    const iconPath = `${this._libPath}/icons/oroshi-active-symbolic.svg`;
    this._icon = new St.Icon({
      style_class: 'system-status-icon',
      icon_size: 16,
      style: 'icon-size: 16px;',
      gicon: Gio.FileIcon.new(Gio.File.new_for_path(iconPath)),
    });
    this._button = new PanelMenu.Button(0.0, INDICATOR_ID, false);
    this._button.add_child(this._icon);
    Main.panel.addToStatusArea(INDICATOR_ID, this._button);
  }

  /**
   * Monkey-patch ubuntu-appindicators' StatusNotifierWatcher to handle Slack's
   * hybrid "busname/path" registration format. Slack sends a string like
   * "org.freedesktop.StatusNotifierItem-1234-5678/StatusNotifierItem" which the
   * original method cannot parse — this wrapper splits it into the path portion
   * so the existing path-based logic handles it correctly.
   */
  _patchWatcher() {
    const appIndicators = Main.extensionManager.lookup(
      'ubuntu-appindicators@ubuntu.com',
    );
    if (!appIndicators) {
      console.warn(
        'OroshiStatuses: ubuntu-appindicators not found, skipping watcher patch',
      );
      return;
    }

    const modulePath = `file://${appIndicators.path}/statusNotifierWatcher.js`;
    import(modulePath)
      .then((mod) => {
        const proto = mod.StatusNotifierWatcher.prototype;
        this._originalRegisterMethod = proto.RegisterStatusNotifierItemAsync;
        this._watcherPrototype = proto;

        const original = this._originalRegisterMethod;
        proto.RegisterStatusNotifierItemAsync = function (params, invocation) {
          const [service] = params;
          // Hybrid format: contains "/" but does not start with "/"
          if (service.includes('/') && service.charAt(0) !== '/') {
            const path = service.substring(service.indexOf('/'));
            console.log(
              `OroshiStatuses: rewrote hybrid registration "${service}" → "${path}"`,
            );
            return original.call(this, [path], invocation);
          }
          return original.call(this, params, invocation);
        };

        console.log(
          'OroshiStatuses: patched StatusNotifierWatcher for hybrid registration',
        );
      })
      .catch((e) => {
        console.warn(
          'OroshiStatuses: failed to patch StatusNotifierWatcher',
          e,
        );
      });
  }

  /** Restore the original RegisterStatusNotifierItemAsync method */
  _unpatchWatcher() {
    if (!this._watcherPrototype || !this._originalRegisterMethod) return;
    this._watcherPrototype.RegisterStatusNotifierItemAsync =
      this._originalRegisterMethod;
    this._watcherPrototype = null;
    this._originalRegisterMethod = null;
    console.log('OroshiStatuses: restored original StatusNotifierWatcher');
  }

  /** Remove the panel button and release its references */
  _destroyButton() {
    if (!this._button) return;
    this._button.destroy();
    this._button = null;
    this._icon = null;
  }
}

/**
 * Bootstrap the OroshiStatuses panel indicators
 * @param {object} extension - The OroshiStatusesExtension instance
 * @returns {OroshiStatuses} Controller with a destroy() method
 */
export function setup(extension) {
  return new OroshiStatuses(extension);
}
