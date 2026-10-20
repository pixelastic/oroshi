import { _ } from 'golgoth';
import { formatPrice } from '../formatPrice.js';

/**
 * Format the recap of the listings to publish for the terminal
 * @param {object} recap - Result of recapListings
 * @param {number} recap.count - Number of draft listings
 * @param {number} recap.total - Total asked price
 * @param {object[]} recap.uncertain - Title and price of uncertain listings
 * @returns {string} Uncertain prices first, then the count and the total
 */
export function formatRecap({ count, total, uncertain }) {
  // Nothing to publish
  if (count === 0) {
    return 'No draft listing found.';
  }

  const uncertainLines = _.isEmpty(uncertain)
    ? []
    : [
        'Uncertain prices:',
        ..._.map(uncertain, ({ title, price }) => {
          return `${title}: ${formatPrice(price)}`;
        }),
      ];

  return [
    ...uncertainLines,
    `${count} ${count === 1 ? 'listing' : 'listings'}`,
    `Total: ${formatPrice(total)}`,
  ].join('\n');
}
