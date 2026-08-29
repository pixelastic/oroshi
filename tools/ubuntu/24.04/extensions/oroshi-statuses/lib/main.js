import Gio from 'gi://Gio';
import GLib from 'gi://GLib';

const SNI_PREFIX = 'org.freedesktop.StatusNotifierItem-';
const SNI_INTERFACE = 'org.kde.StatusNotifierItem';
const SNI_PATH = '/StatusNotifierItem';
const SLACK_ID = 'Slack_status_icon_1';
const PROPERTIES_INTERFACE = 'org.freedesktop.DBus.Properties';

class OroshiStatuses {
  /**
   * @param {object} _extension - The OroshiStatusesExtension instance
   */
  constructor(_extension) {
    this._bus = Gio.DBus.session;
    this._slackBusName = null;
    this._subscriptionIds = [];
    this._cancellable = new Gio.Cancellable();

    this._watchNameChanges();
    this._scanExistingNames();
  }

  /** Tear down all resources and remove the panel indicator */
  destroy() {
    this._cancellable.cancel();
    for (const id of this._subscriptionIds) {
      this._bus.signal_unsubscribe(id);
    }
    this._subscriptionIds = [];
    this._slackBusName = null;
  }

  /**
   * Subscribe to NameOwnerChanged to detect SNI bus names appearing/disappearing
   */
  _watchNameChanges() {
    const id = this._bus.signal_subscribe(
      'org.freedesktop.DBus',
      'org.freedesktop.DBus',
      'NameOwnerChanged',
      '/org/freedesktop/DBus',
      null,
      Gio.DBusSignalFlags.NONE,
      (_connection, _sender, _path, _iface, _signal, params) => {
        const [name, oldOwner, newOwner] = params.deepUnpack();
        if (!name.startsWith(SNI_PREFIX)) return;

        // Name appeared on the bus
        if (newOwner !== '' && oldOwner === '') {
          this._checkIfSlack(name);
          return;
        }

        // Name disappeared from the bus
        if (newOwner === '' && name === this._slackBusName) {
          console.log('OroshiStatuses: Slack removed from D-Bus');
          this._slackBusName = null;
        }
      },
    );
    this._subscriptionIds.push(id);
  }

  /**
   * Scan existing bus names to detect an already-running Slack instance
   */
  _scanExistingNames() {
    this._bus.call(
      'org.freedesktop.DBus',
      '/org/freedesktop/DBus',
      'org.freedesktop.DBus',
      'ListNames',
      null,
      GLib.VariantType.new('(as)'),
      Gio.DBusCallFlags.NONE,
      -1,
      this._cancellable,
      (connection, result) => {
        try {
          const reply = connection.call_finish(result);
          const [names] = reply.deepUnpack();
          for (const name of names) {
            if (name.startsWith(SNI_PREFIX)) {
              this._checkIfSlack(name);
            }
          }
        } catch (e) {
          if (!e.matches(Gio.IOErrorEnum, Gio.IOErrorEnum.CANCELLED)) {
            console.error('OroshiStatuses: failed to list D-Bus names', e);
          }
        }
      },
    );
  }

  /**
   * Call GetAll on an SNI bus name and check if it belongs to Slack
   * @param {string} busName - The D-Bus bus name to query
   */
  _checkIfSlack(busName) {
    this._bus.call(
      busName,
      SNI_PATH,
      PROPERTIES_INTERFACE,
      'GetAll',
      new GLib.Variant('(s)', [SNI_INTERFACE]),
      GLib.VariantType.new('(a{sv})'),
      Gio.DBusCallFlags.NONE,
      -1,
      this._cancellable,
      (connection, result) => {
        try {
          const reply = connection.call_finish(result);
          const [props] = reply.deepUnpack();
          const id = props.Id?.deepUnpack();
          if (id !== SLACK_ID) return;

          this._slackBusName = busName;
          console.log('OroshiStatuses: Slack detected on D-Bus');
        } catch (e) {
          if (!e.matches(Gio.IOErrorEnum, Gio.IOErrorEnum.CANCELLED)) {
            // Not Slack or property retrieval failed — ignore
          }
        }
      },
    );
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
