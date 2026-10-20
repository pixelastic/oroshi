import { _ } from 'golgoth';
import { summarizePrices } from './summarizePrices.js';

const PRICE_RATIO = 0.8;
const MIN_PRICE = 2;
const MIN_CERTAIN_COUNT = 3;
const UNCERTAIN_BASIS = 'few';

/**
 * Compute the price to ask for a listing, from the kept search rows
 * @param {object[]} rows - Kept search rows, with at least a price
 * @param {object} options - Options
 * @param {string} options.basis - Where the rows came from: isbn, title or few
 * @returns {object} Price, median, count, basis and isUncertain
 */
export function computeListingPrice(rows, { basis }) {
  const { median, count } = summarizePrices(_.map(rows, 'price'));

  return {
    price: Math.max(MIN_PRICE, Math.round(PRICE_RATIO * median)),
    median,
    count,
    basis,
    isUncertain: count < MIN_CERTAIN_COUNT || basis === UNCERTAIN_BASIS,
  };
}
