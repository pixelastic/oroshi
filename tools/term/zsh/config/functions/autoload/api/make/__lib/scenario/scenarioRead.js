import { callApi } from '../callApi.js';
import { formatScenario } from './formatScenario.js';

export let __;

/**
 * Read one Scenario of the Team
 * @param {object} options - Id of the Scenario
 * @param {number|string} options.scenarioId - Scenario ID
 * @returns {Promise<object>} The Scenario, formatted
 */
export async function scenarioRead(options) {
  const { scenarioId } = options;

  // The API wraps the Scenario in a scenario key
  const response = await __.callApi(`scenarios/${scenarioId}`);
  return __.formatScenario(response.scenario);
}

__ = {
  callApi,
  formatScenario,
};
