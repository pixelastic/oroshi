import { firostError } from 'firost';
import { assertScenarioId } from '../assertScenarioId.js';
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

  // Check the arguments before calling the API, so a typo costs no request
  assertScenarioId(
    scenarioId,
    'make-execution-read <executionId> --scenarioId <scenarioId>',
  );
  if (!executionId) {
    throw firostError(
      'MAKE_EXECUTION_ID_MISSING',
      'Missing the Execution ID, it is positional. Usage: make-execution-read <executionId> --scenarioId <scenarioId>',
    );
  }

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
