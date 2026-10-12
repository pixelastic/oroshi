import { _ } from 'golgoth';

const FIELD_SEPARATOR = '▮';
const LIST_SEPARATOR = '▯';

/**
 * Format a value as one raw column. Newlines become spaces and separators are
 * removed. A list is joined with the list separator, and a nil value stays
 * empty
 * @param {*} value - Value to format
 * @returns {string} Raw column
 */
export function rawColumn(value) {
  const clean = (item) =>
    _.chain(_.isObject(item) ? JSON.stringify(item) : item)
      .toString()
      .replace(/\s*[\r\n]+\s*/g, ' ')
      .split(FIELD_SEPARATOR)
      .join('')
      .split(LIST_SEPARATOR)
      .join('')
      .value();

  return _.chain(value)
    .castArray()
    .reject(_.isNil)
    .map(clean)
    .join(LIST_SEPARATOR)
    .value();
}
