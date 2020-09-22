const util = require('util');
const exec = util.promisify(require('child_process').exec);
module.exports = {
  async getWindows(sessionName) {
    const tmuxFormat="#{window_active}/#{window_name}/#{window_index}/#{window_zoomed_flag}";
    const { stdout } = await exec(`tmux list-windows -t ${sessionName} -F "${tmuxFormat}"`);

    // Find all windows
    const windows = [];
    let activeIndex = 0;
    stdout.trim().split('\n').forEach((line, lineIndex) => {
      const split = line.split('/');
      const isActive = split[0] === '1';
      const name = split[1];
      const index = split[2];
      const isZoomed = split[3] === '1';

      if (isActive) activeIndex = lineIndex;

      windows.push({ 
        name, 
        index, 
        isZoomed,
        isActive,
      });
    });

    // Mark the after and before the active
    const activeWindow = windows[activeIndex];
    if (windows[activeIndex-1]) {
      windows[activeIndex-1].isBeforeActive = true;
    }
    if (windows[activeIndex+1]) {
      windows[activeIndex+1].isAfterActive = true;
    }

    return windows;
  },
  async getWindow(sessionName, windowName) {
    const windows = await this.getWindows(sessionName);
    return windows.find(thisWindow => { return thisWindow.name === windowName });
  },
  styling(name) {
    const hashes = {
      bg: {
        background: '202'
      },
      perso: {
        background: '141'
      },
      projects: {
        background: '35'
      },
      tmp: {
        background: '233'
      }
    };

    return hashes[name] || {}
  },
  colorize(text, background = '136', foreground = '235') {
    return `#[fg=colour${background},bg=colour${foreground}]${text}#[default]`;
  }

}
