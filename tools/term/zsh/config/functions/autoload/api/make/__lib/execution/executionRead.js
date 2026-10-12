import { callApi } from '../callApi.js';
import { formatExecution } from './formatExecution.js';

export let __;

/**
 * Read one Execution of a Scenario
 * @param {object} options - Ids of the Scenario and the Execution
 * @param {number|string} options.scenarioId - Scenario ID, the anchor
 * @param {string} options.executionId - Execution ID
 * @returns {Promise<object>} The Execution, formatted
 */
export async function executionRead(options) {
  const { scenarioId, executionId } = options;

  // The API wraps the Execution in a scenarioLog key
  const response = await __.callApi(
    `scenarios/${scenarioId}/logs/${executionId}`,
  );
  return __.formatExecution(response.scenarioLog);
}

__ = {
  callApi,
  formatExecution,
};
