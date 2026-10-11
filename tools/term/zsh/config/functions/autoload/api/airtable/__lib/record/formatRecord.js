import { _ } from 'golgoth';

/**
 * Format one Record of the API, to give every command the same output
 * @param {object} response - The Record, as returned by the API
 * @returns {object} The Record as { id, fields }, with the Fields nested
 */
export function formatRecord(response) {
  return _.pick(response, ['id', 'fields']);
}
