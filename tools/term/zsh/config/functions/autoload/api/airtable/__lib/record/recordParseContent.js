import { _ } from 'golgoth';
import { firostError, readJson } from 'firost';

export let __;

/**
 * Get the content of a Record, from a data file, or inline. The data file wins
 * over the inline content
 * @param {object} options - Where the content comes from
 * @param {string|object} [options.content] - Inline JSON string, or the object itself
 * @param {string} [options.dataFile] - Path to a JSON file
 * @returns {Promise<object>} The Fields, as a plain object
 */
export async function recordParseContent(options) {
  const { content, dataFile } = options;

  let parsed;
  try {
    parsed = dataFile ? await readJson(dataFile) : __.parseInline(content);
  } catch (error) {
    throw firostError(
      'AIRTABLE_CONTENT_INVALID',
      `The content is not valid JSON: ${error.message}`,
    );
  }

  if (!_.isPlainObject(parsed)) {
    throw firostError(
      'AIRTABLE_CONTENT_INVALID',
      'Pass the content as a JSON object, or with --data-file',
    );
  }
  return parsed;
}

__ = {
  /**
   * Parse the inline content, when it is a string
   * @param {string|object} [content] - Inline JSON string, or the object itself
   * @returns {object|undefined} The parsed content, undefined if there is none
   */
  parseInline(content) {
    return _.isString(content) ? JSON.parse(content) : content;
  },
};
