import { _ } from 'golgoth';
import { callApi } from '../callApi.js';
import { getConfig } from '../getConfig.js';
import { pageSizes } from '../pageSizes.js';
import { paginate } from '../paginate.js';
import { formatScenario } from './formatScenario.js';

export let __;

const DEFAULT_LIMIT = 25;

/**
 * Search the Scenarios of the Team by name, and tell if more exist
 * @param {object} [options] - Search options
 * @param {string} [options.query] - Text to look for in the names, all Scenarios by default
 * @param {number|string} [options.folderId] - Only the Scenarios directly in this Folder
 * @param {number} [options.limit] - Maximum number of Scenarios
 * @returns {Promise<object>} The Scenarios, formatted, and hasMore, true when more Scenarios exist than the limit
 */
export async function scenarioSearchPaged(options = {}) {
  const { query, folderId, limit = DEFAULT_LIMIT } = options;

  const { teamId } = await __.getConfig();
  const { items, hasMore } = await __.paginate(
    async ({ offset, limit: pageLimit }) => {
      const response = await __.callApi('scenarios', {
        query: {
          teamId,
          search: query || undefined,
          folderId,
          'pg[offset]': offset,
          'pg[limit]': pageLimit,
        },
      });
      return response.scenarios;
    },
    { limit, pageSize: pageSizes.scenario },
  );

  return { scenarios: _.map(items, __.formatScenario), hasMore };
}

__ = {
  callApi,
  getConfig,
  paginate,
  formatScenario,
};
