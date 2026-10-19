import { firostError } from 'firost';

const ITEM_BASE_URL = 'https://www.vinted.fr/items';
const ITEM_ID_PATTERN = /^(?:\d+|https?:\/\/[^/]+\/items\/(\d+)(?:[-/?#].*)?)$/;

/**
 * Resolve a listing id or URL into the URL of its edit form
 * @param {string} idOrUrl - Listing id, or URL of the listing
 * @returns {string} URL of the edit form
 */
export function resolveEditUrl(idOrUrl) {
  const match = ITEM_ID_PATTERN.exec(idOrUrl);
  const id = match?.[1] ?? (match ? idOrUrl : null);
  if (!id) {
    throw firostError(
      'VINTED_LISTING_ID_INVALID',
      `"${idOrUrl}" is neither a listing id nor a listing URL`,
    );
  }
  return `${ITEM_BASE_URL}/${id}/edit`;
}
