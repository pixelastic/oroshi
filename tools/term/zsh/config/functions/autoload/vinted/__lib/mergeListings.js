import { _ } from 'golgoth';

/**
 * Merge the listings of several searches, keeping each listing once
 * @param {object[][]} searches - Listings of each search, as { id, price }
 * @returns {object[]} Unique listings, in order of first appearance
 */
export function mergeListings(searches) {
  return _.chain(searches).flatten().uniqBy('id').value();
}
