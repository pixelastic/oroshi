import { _ } from 'golgoth';

/**
 * Format one Scenario of the API, to keep only what is useful to read it
 * @param {object} response - The Scenario, as returned by the API
 * @returns {object} The Scenario, without operations, users, devices and other noise
 */
export function formatScenario(response) {
  return _.pick(response, [
    'id',
    'name',
    'folderId',
    'isActive',
    'scheduling',
    'lastEdit',
    'nextExec',
  ]);
}
