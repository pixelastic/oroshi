import path from 'node:path';
import { readJson } from 'firost';

export let __;

const ICONS_RELATIVE_PATH = 'tools/term/zsh/config/theming/dist/icons.json';

/**
 * Read the separators of the raw format from the design system icons
 * @returns {Promise<object>} { field, list }, between the fields of a line and between the items of a list field
 */
export async function gmailSeparators() {
  const icons = await __.readIcons();
  return {
    field: icons['table-separator'],
    list: icons['table-separator-secondary'],
  };
}

__ = {
  /**
   * Read the design system icon definitions
   * @returns {Promise<object>} Icons by name
   */
  readIcons() {
    return readJson(path.resolve(process.env.OROSHI_ROOT, ICONS_RELATIVE_PATH));
  },
};
