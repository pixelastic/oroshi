import { _ } from 'golgoth';

/**
 * Read one header of a mail, case-insensitively
 * @param {object} mail - Gmail message resource
 * @param {string} name - Header name
 * @returns {string} Header value, or an empty string
 */
export function header(mail, name) {
  return _.chain(mail.payload?.headers)
    .find((item) => _.toLower(item.name) === _.toLower(name))
    .get('value', '')
    .value();
}
