import { _ } from 'golgoth';

const ITEM_ID_PATTERN = /\/items\/(\d+)/g;

/**
 * Extract the ids of the sold items from the sales page markup
 * Every item link holds the id. Links without an id are ignored.
 * @param {string} html - Markup of the sales page
 * @returns {string[]} Unique item ids, in page order
 */
export function parseSoldIds(html) {
  return _.chain([...html.matchAll(ITEM_ID_PATTERN)])
    .map(1)
    .uniq()
    .value();
}
