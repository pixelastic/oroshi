import { _ } from 'golgoth';
import { firostError } from 'firost';
import { assertScenarioId } from '../assertScenarioId.js';
import { callApi } from '../callApi.js';
import { defaultLimit } from '../defaultLimit.js';
import { pageSizes } from '../pageSizes.js';
import { paginate } from '../paginate.js';
import { formatExecution } from './formatExecution.js';

export let __;

const STATUS_CODES = { success: 1, warning: 2, error: 3 };

/**
 * Search the Executions of a Scenario, newest first, and tell if more exist
 * @param {object} options - Anchor and filters
 * @param {number|string} options.scenarioId - Scenario ID, the anchor
 * @param {string} [options.status] - success, warning or error
 * @param {string} [options.dateMin] - ISO 8601 date, a date without time is midnight UTC
 * @param {string} [options.dateMax] - ISO 8601 date, a date without time is midnight UTC
 * @param {number} [options.limit] - Maximum number of Executions
 * @returns {Promise<object>} The results (the Executions, formatted) and hasMore, true when more Executions exist than the limit
 */
export async function executionSearch(options) {
  const {
    scenarioId,
    status,
    dateMin,
    dateMax,
    limit = defaultLimit,
  } = options;

  assertScenarioId(
    scenarioId,
    'make-execution-search --scenarioId <scenarioId> [--status <status>]',
  );

  // Convert the flags before calling the API, so a typo costs no request
  const query = {
    status: __.toStatusCode(status),
    from: __.toTimestamp(dateMin),
    to: __.toTimestamp(dateMax),
  };
  const { items, hasMore } = await __.paginate(
    async ({ offset, limit: pageLimit }) => {
      const response = await __.callApi(`scenarios/${scenarioId}/logs`, {
        query: _.omitBy(
          { ...query, 'pg[offset]': offset, 'pg[limit]': pageLimit },
          _.isUndefined,
        ),
      });

      // The API names the Executions scenarioLogs
      return response.scenarioLogs;
    },
    { limit, pageSize: pageSizes.execution },
  );

  return { results: _.map(items, __.formatExecution), hasMore };
}

__ = {
  /**
   * Convert a status name to the code of the API
   * @param {string} [status] - success, warning or error
   * @returns {number|undefined} The code, undefined without status
   */
  toStatusCode(status) {
    if (_.isUndefined(status)) {
      return undefined;
    }
    const code = STATUS_CODES[status];
    if (!code) {
      throw firostError(
        'MAKE_INVALID_STATUS',
        `Status must be one of ${_.chain(STATUS_CODES).keys().join(', ').value()}, got "${status}"`,
      );
    }
    return code;
  },
  /**
   * Convert an ISO 8601 date to milliseconds
   * @param {string} [date] - ISO 8601 date, a date without time is midnight UTC
   * @returns {number|undefined} The milliseconds, undefined without date
   */
  toTimestamp(date) {
    if (_.isUndefined(date)) {
      return undefined;
    }
    const timestamp = Date.parse(date);
    if (_.isNaN(timestamp)) {
      throw firostError(
        'MAKE_INVALID_DATE',
        `Date must follow ISO 8601, got "${date}"`,
      );
    }
    return timestamp;
  },
  callApi,
  paginate,
  formatExecution,
};
