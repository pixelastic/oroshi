import { _ } from 'golgoth';

/**
 * Format one Database, to give every command the same output
 * @param {object} response - The Database, with its `properties`
 * @returns {object} The Database as { id, url, title, properties }, with the title as plain text
 */
export function formatDatabase(response) {
  const { id, url, properties } = response;
  const title = _.chain(response.title).map('plain_text').join('').value();

  return { id, url, title, properties };
}
