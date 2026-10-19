import { _ } from 'golgoth';
import { firostError } from 'firost';

export let __;

/**
 * Summarize a list of prices
 * @param {number[]} prices - Prices, in any order
 * @returns {object} Count, min, max, median and quartiles
 */
export function summarizePrices(prices) {
  if (_.isEmpty(prices)) {
    throw firostError(
      'VINTED_PRICE_NO_RESULT',
      'No listing found, no price to summarize',
    );
  }

  const sorted = _.sortBy(prices);
  return {
    count: sorted.length,
    min: _.first(sorted),
    max: _.last(sorted),
    median: __.quantile(sorted, 0.5),
    firstQuartile: __.quantile(sorted, 0.25),
    thirdQuartile: __.quantile(sorted, 0.75),
  };
}

__ = {
  /**
   * Compute a quantile with linear interpolation between neighbours
   * @param {number[]} sorted - Prices, sorted in ascending order
   * @param {number} ratio - Quantile to compute, between 0 and 1
   * @returns {number} Value at the quantile
   */
  quantile(sorted, ratio) {
    const position = ratio * (sorted.length - 1);
    const lowerIndex = Math.floor(position);
    const upperIndex = Math.ceil(position);
    const weight = position - lowerIndex;
    return sorted[lowerIndex] * (1 - weight) + sorted[upperIndex] * weight;
  },
};
