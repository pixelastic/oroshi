import { firostError } from 'firost';

/**
 * Get the bare id of a Page from a Page URL or an id
 * @param {string} input - A Page URL, or a bare id
 * @returns {string} The id of the Page
 */
export function parsePageId(input = '') {
  // A bare id passes through
  if (/^\d+$/.test(input)) {
    return input;
  }

  // In a Page URL, the id is the digits after /pages/
  const match = input.match(/\/pages\/(\d+)(?:[/?#]|$)/);
  if (!match) {
    throw firostError(
      'CONFLUENCE_ID_INVALID',
      `No Confluence page id found in "${input}"`,
    );
  }

  return match[1];
}
