import { firostError } from 'firost';

export let __;

/**
 * Get the bare id of a Page from a Page URL or an id
 * @param {string} input - A Page URL, a short link, or a bare id
 * @returns {string} The id of the Page
 */
export function parsePageId(input = '') {
  // A bare id passes through
  if (/^\d+$/.test(input)) {
    return input;
  }

  // In a Page URL, the id is the digits after /pages/
  const match = input.match(/\/pages\/(\d+)(?:[/?#]|$)/);
  if (match) {
    return match[1];
  }

  // In a short link, the id is encoded in the token after /x/
  const shortMatch = input.match(/\/wiki\/x\/([\w-]+)(?:[/?#]|$)/);
  if (shortMatch) {
    return __.decodeShortToken(shortMatch[1]);
  }

  throw firostError(
    'CONFLUENCE_ID_INVALID',
    `No Confluence page id found in "${input}"`,
  );
}

__ = {
  /**
   * Decode the token of a short link into a page id
   * The token is the base64url of the id, as little-endian bytes
   * @param {string} token - Token of the short link
   * @returns {string} The id of the Page
   */
  decodeShortToken(token) {
    const bytes = Buffer.from(token, 'base64url');
    const hex = Buffer.from(bytes).reverse().toString('hex');
    return BigInt(`0x${hex || '0'}`).toString();
  },
};
