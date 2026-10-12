import { resolve } from 'node:path';
import { _ } from 'golgoth';
import { readJson } from 'firost';

export let __;

/**
 * Get a JSON value from the options of a command, from a file or inline
 * The file, in the `<key>File` option, wins over the inline value, in the `<key>` option
 * @param {object} options - Options of the command
 * @param {string} key - Name of the inline option. The file option is named `<key>File`
 * @param {object} [fallback] - Value when there is neither
 * @returns {Promise<object|undefined>} The parsed value
 */
export async function getJsonFromOptions(options, key, fallback) {
  const filepath = options[`${key}File`];
  const inline = options[key];

  if (filepath) {
    // firost resolves a relative path from its own folder, not from the caller
    return await __.readJson(resolve(filepath));
  }
  return _.isString(inline) ? JSON.parse(inline) : (inline ?? fallback);
}

__ = {
  readJson,
};
