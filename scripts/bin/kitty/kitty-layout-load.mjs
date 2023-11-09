#!/usr/bin/env zx
/**
 * Alt-Shift-S Saves the current Kitty layout configuration in a file
 * Alt-Shift-L Will reload it
 
 * Kitty startup session are great, but they have limitations.
 * They can only follow a linear set of instructions and can't change
 * the focus to a specific window, preventing us from replicating complex
 * layouts.
 *
 * Thankfull, Kitty comes with remote control, and it is possible to do much
 * more with it.
 *
 * The current script will transform the saved layout configuration into a set
 * of kitty remote instructions, save it to a file, and run it.
 **/

import { _ } from 'golgoth';
import firost from 'firost';

const tmpDir = path.resolve(os.homedir(), 'local/tmp/kitty');
const manifest = {};
const KittyLoad = {
  // The save is the JSON file extracted by kitty-save
  saveFilepath: path.resolve(tmpDir, 'save.json'),
  // The script is the final script executing kitty-remote commands we're
  // building
  scriptFilepath: path.resolve(tmpDir, 'kitty-load-script'),
  scriptContent: [],
  async run() {
    const tabs = this.getTabs();
    this.populateManifest(tabs);

    // Add all tabs to script
    _.each(tabs, (tab) => {
      this.addTabToScript(tab);
    });

    // Focus last focused window
    this.comment();
    this.comment('FOCUSING MAIN WINDOW');
    const lastFocusedWindow = _.find(manifest, {
      isFocused: true,
      isTabFocused: true,
    });
    this.addFocusToScript(lastFocusedWindow);

    // Write commands to file and execute it
    await this.runScript();
  },
  getTabs() {
    try {
      const rawTabs = require(this.saveFilepath)[0].tabs;
      return _.reject(rawTabs, { title: 'Saving...' });
    } catch (e) {
      console.info(`Unable to read ${this.saveFilepath}`);
      firost.exit(1);
    }
  },
  /**
   * Populates the manifest variable:
   *  - Each key is an id as references on layout_state
   *  - Each value is the corresponding window data
   *
   * Explanation: The layout_state key contains references to groups, which in
   * turn contain references to windows. We'll create a better matching, where
   * the id in layout_state matches an entry in the manifest, referencing
   * a window.
   *
   * Each key is the state_layout id, each value the window data
   * @param {Array} tabs All tabs saved with kitty-save
   **/
  populateManifest(tabs) {
    _.each(tabs, (tab) => {
      const tabId = tab.id;
      const isTabFocused = tab.is_focused;

      // We create a mapping of windowId to window data
      const windows = {};
      _.each(tab.windows, (window) => {
        const uuid = firost.uuid();
        const { id, cmdline, cwd, env, is_focused } = window;
        const windowId = id;
        // const isFirstWindow = firstWindowId == windowId;
        const isFocused = is_focused;
        windows[id] = {
          tabId,
          windowId,
          isTabFirstWindow: false,
          isFocused,
          isTabFocused,
          cmdline,
          cwd,
          env,
          uuid,
        };
      });

      // We save in the global manifest a reference from each group id to the
      // matching window
      _.each(tab.groups, (group) => {
        // Each group seem to only have one window
        const windowId = group.windows[0];
        const groupId = group.id;
        manifest[groupId] = {
          groupId,
          ...windows[windowId],
        };
      });

      // We mark the first window of this tab as the first window
      const tabFirstWindowId = this.getMainSplitWindowId(
        tab.layout_state.pairs
      );
      manifest[tabFirstWindowId].isTabFirstWindow = true;
    });
  },
  /**
   * Get the kitty remote instructions to create the specified tab
   * @param {object} tab Tab to replicate
   **/
  addTabToScript(tab) {
    const { id, title, layout, layout_state } = tab;

    // Failsafe: We don't currently handle non-splits layouts
    if (layout != 'splits') {
      return;
    }

    this.comment();
    this.comment(`NEW TAB: ${title}`);

    // Create a new tab with the first window in it
    const firstWindow = _.find(manifest, {
      tabId: id,
      isTabFirstWindow: true,
    });
    this.kitty('launch', {
      type: 'tab',
      'tab-title': title,
      cwd: firstWindow.cwd,
      var: `OROSHI_RESTORE_UUID=${firstWindow.uuid}`,
    });
    this.kitty('goto-layout', layout);

    // Recursivly apply all splits
    this.addSplitToScript(layout_state.pairs, firstWindow);

    // Focus the previously focused window in that tab
    this.comment('FOCUSING WINDOW');
    const focusedWindow = _.find(manifest, { tabId: id, isFocused: true });
    this.addFocusToScript(focusedWindow);
  },
  addSplitToScript(layoutState) {
    // If the layout is an integer, it's a leaf and will already have been
    // created
    if (_.isInteger(layoutState)) {
      return;
    }

    // If there are no further split to do, we can also stop
    if (!layoutState.two) {
      return;
    }

    // Focus the main window
    const mainWindow = manifest[this.getMainSplitWindowId(layoutState.one)];
    this.kitty('focus-window', {
      match: `var:OROSHI_RESTORE_UUID=${mainWindow.uuid}`,
    });

    // Split the window
    const secondaryWindow =
      manifest[this.getMainSplitWindowId(layoutState.two)];
    const location = layoutState.horizontal ? 'vsplit' : 'hsplit';

    this.kitty('launch', {
      type: 'window',
      location,
      var: `OROSHI_RESTORE_UUID=${secondaryWindow.uuid}`,
      cwd: secondaryWindow.cwd,
    });

    // Do the same for the other children
    this.addSplitToScript(layoutState.one);
    this.addSplitToScript(layoutState.two);
  },
  /**
   * Find which window is the main window of a split. It means the one you find
   * if you go deep into the chain of one.one.one, etc
   * @param {object} layoutState WindowID or split state
   * @returns {number} Id of the window in the manifets
   **/
  getMainSplitWindowId(layoutState) {
    if (_.isInteger(layoutState)) {
      return layoutState;
    }
    return this.getMainSplitWindowId(layoutState.one);
  },
  /**
   * Put the focus on the last focused window of the last focused tab
   * @param focusedWindow
   **/
  addFocusToScript(focusedWindow) {
    this.kitty('focus-window', {
      match: `var:OROSHI_RESTORE_UUID=${focusedWindow.uuid}`,
    });
  },
  /**
   * Build a kitty remote command
   * @param {string} method Name of the method
   * @param {object} options Hash of arguments
   **/
  kitty(method, options = null) {
    const result = ['kitty @', `--to unix:${tmpDir}/kitty-socket`, method];

    // Passing all options as --flags
    if (_.isObject(options)) {
      _.each(options, (value, key) => {
        result.push(`--${key} ${value}`);
      });
    }

    // Passing single option as-is
    if (_.isString(options)) {
      result.push(options);
    }

    this.scriptContent.push(result.join(' '));
  },
  /**
   * Add a comment in the final script file
   * @param {string} comment Comment to add
   **/
  comment(comment) {
    if (!comment) {
      this.scriptContent.push('');
    } else {
      this.scriptContent.push(`# ${comment}`);
    }
  },
  async runScript() {
    const content = [
      '#!/usr/bin/env zsh',
      '# THIS FILE IS AUTOGENERATED',
      "# Check the kitty-layout-load script to see how it's done",
      '',
      ...this.scriptContent,
    ].join('\n');
    await firost.write(content, this.scriptFilepath);
    await firost.run(`chmod +x ${this.scriptFilepath}`);
    console.info(content);
    await firost.run(this.scriptFilepath);
  },
};

(async () => {
  await KittyLoad.run();
})();
