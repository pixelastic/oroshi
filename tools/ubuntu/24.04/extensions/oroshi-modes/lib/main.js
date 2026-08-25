import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import St from 'gi://St';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';

const HOME = GLib.get_home_dir();
const MODES_DIR = `${HOME}/local/tmp/oroshi/modes`;
const COLORS_PATH = `${HOME}/.oroshi/tools/term/zsh/config/theming/dist/colors.json`;

const INDICATORS = [
  {
    name: 'sound',
    file: 'sound',
    defaultValue: 'disabled',
    values: {
      enabled: { icon: 'sound-enabled.svg', color: 'modes-sound-enabled' },
      disabled: { icon: 'sound-disabled.svg', color: 'modes-sound-disabled' },
    },
  },
  {
    name: 'autosubmit',
    file: 'mic2txt-autosubmit',
    defaultValue: 'disabled',
    values: {
      enabled: {
        icon: 'autosubmit-enabled.svg',
        color: 'modes-autosubmit-enabled',
      },
      disabled: {
        icon: 'autosubmit-disabled.svg',
        color: 'modes-autosubmit-disabled',
      },
    },
  },
  {
    name: 'language',
    file: 'mic2txt-language',
    defaultValue: 'fr',
    values: {
      en: { icon: 'language-en.svg', color: 'modes-language-en' },
      fr: { icon: 'language-fr.svg', color: 'modes-language-fr' },
    },
  },
  {
    name: 'slack',
    file: 'mic2txt-slack',
    defaultValue: 'disabled',
    values: {
      enabled: { icon: 'slack-enabled.svg', color: 'modes-slack-enabled' },
      disabled: { icon: 'slack-disabled.svg', color: 'modes-slack-disabled' },
    },
  },
  {
    name: 'model',
    file: 'mic2txt-model',
    defaultValue: 'openai',
    values: {
      openai: { icon: 'model-openai.svg', color: 'modes-model-openai' },
      groq: { icon: 'model-groq.svg', color: 'modes-model-groq' },
      parakeet: { icon: 'model-parakeet.svg', color: 'modes-model-parakeet' },
    },
  },
];

class OroshiModes {
  constructor(extension) {
    this._extensionPath = extension.path;
    this._iconsDir = `${extension.path}/icons`;
    this._colors = {};
    this._entries = [];
    this._monitors = [];

    this._button = new PanelMenu.Button(0.0, 'OroshiModes', false);
    this._box = new St.BoxLayout({
      style_class: 'panel-status-indicators-box',
    });
    this._button.add_child(this._box);

    this._loadColors();
    this._createIndicators();
    this._setupMonitors();

    Main.panel.addToStatusArea('oroshi-modes', this._button, 0, 'right');
  }

  /**
   * Parse dist/colors.json and extract all modes-* hex values
   */
  _loadColors() {
    try {
      const file = Gio.File.new_for_path(COLORS_PATH);
      const [, contents] = file.load_contents(null);
      const json = JSON.parse(new TextDecoder().decode(contents));

      this._colors = {};
      for (const key of Object.keys(json)) {
        if (key.startsWith('modes-')) {
          this._colors[key] = json[key].hex;
        }
      }
    } catch (e) {
      console.error('OroshiModes: failed to load colors', e);
    }
  }

  /**
   * Read a mode value from its store file, falling back to the default
   * @param {object} config - Indicator config from INDICATORS
   * @returns {string} Current mode value
   */
  _readMode(config) {
    try {
      const file = Gio.File.new_for_path(`${MODES_DIR}/${config.file}`);
      const [, contents] = file.load_contents(null);
      const value = new TextDecoder().decode(contents).trim();
      if (value in config.values) return value;
      return config.defaultValue;
    } catch (_e) {
      return config.defaultValue;
    }
  }

  /**
   * Resolve the icon+color mapping for a given indicator value
   * @param {object} config - Indicator config from INDICATORS
   * @param {string} value - Current mode value
   * @returns {object} { icon, color } mapping
   */
  _resolveMapping(config, value) {
    return config.values[value] || config.values[config.defaultValue];
  }

  /**
   * Build a Gio.BytesIcon from an SVG file, injecting the given hex color
   * @param {string} filename - SVG filename in the icons directory
   * @param {string} hex - Hex color to replace currentColor with
   * @returns {Gio.BytesIcon} Icon with baked-in color
   */
  _makeGicon(filename, hex) {
    const file = Gio.File.new_for_path(`${this._iconsDir}/${filename}`);
    const [, contents] = file.load_contents(null);
    let svg = new TextDecoder().decode(contents);
    svg = svg.replaceAll('currentColor', hex);
    return new Gio.BytesIcon({
      bytes: new GLib.Bytes(new TextEncoder().encode(svg)),
    });
  }

  /**
   * Create the 5 St.Icon widgets, each wrapped in an St.Bin, and add to the box
   */
  _createIndicators() {
    for (const config of INDICATORS) {
      const value = this._readMode(config);
      const mapping = this._resolveMapping(config, value);
      const hex = this._colors[mapping.color] || '#ffffff';

      const icon = new St.Icon({
        gicon: this._makeGicon(mapping.icon, hex),
        icon_size: 20,
        style_class: 'system-status-icon oroshi-mode-icon',
      });

      const bin = new St.Bin({ child: icon });
      this._box.add_child(bin);
      this._entries.push({ config, icon, value });
    }
  }

  /**
   * Re-read a single indicator's mode file and update icon + color
   * @param {object} entry - Entry from this._entries
   */
  _updateIndicator(entry) {
    const value = this._readMode(entry.config);
    if (value === entry.value) return;

    const mapping = this._resolveMapping(entry.config, value);
    const hex = this._colors[mapping.color] || '#ffffff';
    entry.icon.gicon = this._makeGicon(mapping.icon, hex);
    entry.value = value;
  }

  /**
   * Re-read colors.json and re-apply colors to all indicators
   */
  _refreshColors() {
    this._loadColors();
    for (const entry of this._entries) {
      const mapping = this._resolveMapping(entry.config, entry.value);
      const hex = this._colors[mapping.color] || '#ffffff';
      entry.icon.gicon = this._makeGicon(mapping.icon, hex);
    }
  }

  /**
   * Set up Gio.FileMonitors on the modes directory and colors.json
   */
  _setupMonitors() {
    // Ensure the modes directory exists so we can monitor it
    const modesDir = Gio.File.new_for_path(MODES_DIR);
    try {
      modesDir.make_directory_with_parents(null);
    } catch (_e) {
      // Already exists
    }

    const modesMonitor = modesDir.monitor_directory(
      Gio.FileMonitorFlags.NONE,
      null,
    );
    modesMonitor.connect('changed', (_monitor, file, _other, eventType) => {
      if (eventType !== Gio.FileMonitorEvent.CHANGES_DONE_HINT) return;

      const basename = file.get_basename();
      for (const entry of this._entries) {
        if (entry.config.file === basename) {
          this._updateIndicator(entry);
          break;
        }
      }
    });
    this._monitors.push(modesMonitor);

    const colorsFile = Gio.File.new_for_path(COLORS_PATH);
    const colorsMonitor = colorsFile.monitor_file(
      Gio.FileMonitorFlags.NONE,
      null,
    );
    colorsMonitor.connect('changed', (_monitor, _file, _other, eventType) => {
      if (eventType !== Gio.FileMonitorEvent.CHANGES_DONE_HINT) return;
      this._refreshColors();
    });
    this._monitors.push(colorsMonitor);
  }

  /**
   * Tear down all monitors, remove the panel button, release references
   */
  destroy() {
    for (const monitor of this._monitors) {
      monitor.cancel();
    }
    this._monitors = [];
    this._entries = [];
    this._button.destroy();
    this._button = null;
  }
}

/**
 * Bootstrap the OroshiModes panel indicators
 * @param {object} extension - The OroshiModesExtension instance
 * @returns {OroshiModes} Controller with a destroy() method
 */
export function setup(extension) {
  return new OroshiModes(extension);
}
