import { _ } from 'golgoth';

/**
 * Format one Page of the API, to give every command the same output
 * @param {object} response - The Page, as returned by the API
 * @returns {object} The Page as { id, url, properties }, without its icon and cover
 */
export function formatPage(response) {
  return _.pick(response, ['id', 'url', 'properties']);
}
