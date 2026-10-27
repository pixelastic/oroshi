import { _ } from 'golgoth';

/**
 * Read one header of a Message, case-insensitively
 * @param {object} message - Gmail message resource
 * @param {string} name - Header name
 * @returns {string} Header value, or an empty string
 */
export function header(message, name) {
  return _.chain(message.payload?.headers)
    .find((item) => _.toLower(item.name) === _.toLower(name))
    .get('value', '')
    .value();
}
