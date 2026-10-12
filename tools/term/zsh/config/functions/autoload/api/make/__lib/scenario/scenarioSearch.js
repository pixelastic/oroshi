import { _ } from 'golgoth';
import { callApi } from '../callApi.js';
import { getConfig } from '../getConfig.js';
import { formatScenario } from './formatScenario.js';

export let __;

const DEFAULT_LIMIT = 25;

/**
 * Search the Scenarios of the Team by name
 * @param {object} [options] - Search options
 * @param {string} [options.query] - Text to look for in the names, all Scenarios by default
 * @param {number} [options.limit] - Maximum number of Scenarios
 * @returns {Promise<object[]>} The Scenarios, formatted
 */
export async function scenarioSearch(options = {}) {
  const { query, limit = DEFAULT_LIMIT } = options;

  const { teamId } = await __.getConfig();
  const response = await __.callApi('scenarios', {
    query: {
      teamId,
      search: query || undefined,
      'pg[limit]': limit,
    },
  });

  return _.map(response.scenarios, __.formatScenario);
}

__ = {
  callApi,
  getConfig,
  formatScenario,
};
