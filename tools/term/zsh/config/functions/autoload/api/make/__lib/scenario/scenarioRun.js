import { _ } from 'golgoth';
import { getJsonFromOptions } from '@oroshi/api-shared/getJsonFromOptions.js';
import { callApi } from '../callApi.js';

export let __;

/**
 * Run one Scenario of the Team. The Scenario must be enabled
 * @param {object} options - Id of the Scenario, and how to run it
 * @param {number|string} options.scenarioId - Scenario ID
 * @param {string|object} [options.data] - Inputs as a JSON string, or the object itself
 * @param {string} [options.dataFile] - Path to a JSON file of the inputs. Wins over data
 * @param {boolean} [options.wait] - Wait for the end of the execution (40 seconds at most)
 * @returns {Promise<string|object>} The execution ID, or with wait the response holding status and outputs
 */
export async function scenarioRun(options) {
  const { scenarioId, wait } = options;

  const dataContent = await __.getJsonFromOptions(options, 'data');

  // Keep only the given keys, so a missing data or responsive is not sent
  const body = _.omitBy(
    {
      data: dataContent,
      responsive: wait ? true : undefined,
    },
    _.isUndefined,
  );
  const response = await __.callApi(`scenarios/${scenarioId}/run`, {
    method: 'POST',
    body,
  });

  return wait ? response : response.executionId;
}

__ = {
  callApi,
  getJsonFromOptions,
};
