// Bootstrap for the oroshi-statuses GNOME Shell extension.
// This file is loaded once by GNOME Shell and cached forever (GJS caches ESM
// modules by specifier for the lifetime of the process). It should rarely need
// to change — the real code lives in main.js, loaded dynamically below.
import Gio from 'gi://Gio';
import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';

export default class OroshiStatusesExtension extends Extension {
  /** Load the dynamic main module on extension enable */
  enable() {
    this._load();
  }

  /** Tear down the main module on extension disable */
  disable() {
    this._main?.destroy();
    this._main = null;
  }

  /**
   * Hot-reload trick: GJS caches modules by their import path string, not by
   * the resolved file on disk.
   *
   * Our reload script (oroshi-statuses/reload) write a random token to
   * dist/token, and symlink the main lib/ folder from dist/<token>.
   *
   * Now, we just need to read dist/token to know where to read from. From GJS
   * POV it's a completely different file, not in cache, because it has a
   * different path. This allows a hacky way to reload the code without having
   * to log out/log in.
   */
  async _load() {
    const tokenPath = `${this.path}/dist/token`;
    const tokenFile = Gio.File.new_for_path(tokenPath);

    const [, contents] = tokenFile.load_contents(null);
    const token = new TextDecoder().decode(contents).trim();
    const mod = await import(`./dist/${token}/main.js`);
    this._main = mod.setup(this);
  }
}
