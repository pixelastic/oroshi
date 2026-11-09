import { _ } from 'golgoth';
import { firostError } from 'firost';

/**
 * Convert the limit to a positive integer
 * @param {number|string} limit - The limit, as a number or as typed in a flag
 * @returns {number} The limit
 */
export function toLimit(limit) {
  const value = _.isString(limit) && limit.trim() === '' ? NaN : Number(limit);
  if (!Number.isInteger(value) || value < 1) {
    throw firostError(
      'CIRCLECI_INVALID_ARGUMENT',
      `--limit must be a positive integer, got "${limit}"`,
    );
  }
  return value;
}
