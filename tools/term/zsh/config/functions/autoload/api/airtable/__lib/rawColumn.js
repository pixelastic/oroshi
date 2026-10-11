import { _ } from 'golgoth';

/**
 * Format a value as one raw column. Newlines become spaces and separators are
 * removed. A list is joined with the list separator, and a nil value stays
 * empty
 * @param {*} value - Value to format
 * @param {object} separators - { field, list }
 * @returns {string} Raw column
 */
export function airtableRawColumn(value, separators) {
  const clean = (item) =>
    _.chain(_.isObject(item) ? JSON.stringify(item) : item)
      .toString()
      .replace(/\s*[\r\n]+\s*/g, ' ')
      .split(separators.field)
      .join('')
      .split(separators.list)
      .join('')
      .value();

  return _.chain(value)
    .castArray()
    .reject(_.isNil)
    .map(clean)
    .join(separators.list)
    .value();
}
