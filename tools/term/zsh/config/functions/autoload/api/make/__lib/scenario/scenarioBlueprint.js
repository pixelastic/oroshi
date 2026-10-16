import { callApi } from '../callApi.js';
import { assertPositionalScenarioId } from './assertPositionalScenarioId.js';

export let __;

/**
 * Read the full blueprint of one Scenario, with its mappers and parameters
 * @param {object} options - Id of the Scenario
 * @param {number|string} options.scenarioId - Scenario ID
 * @returns {Promise<object>} The blueprint, as the API gives it
 */
export async function scenarioBlueprint(options) {
  const { scenarioId } = options;

  // Check the argument before calling the API, so a typo costs no request
  assertPositionalScenarioId(
    scenarioId,
    'make-scenario-blueprint <scenarioId>',
  );

  // The API wraps the blueprint in response.blueprint
  const response = await __.callApi(`scenarios/${scenarioId}/blueprint`);
  return response.response.blueprint;
}

__ = {
  callApi,
};
