import { callApi } from '../callApi.js';
import { buildFlow } from './buildFlow.js';
import { formatScenario } from './formatScenario.js';

export let __;

/**
 * Read one Scenario of the Team, with the nested flow of its modules
 * @param {object} options - Id of the Scenario
 * @param {number|string} options.scenarioId - Scenario ID
 * @returns {Promise<object>} The Scenario, formatted, with its flow
 */
export async function scenarioRead(options) {
  const { scenarioId } = options;

  // The API wraps the Scenario in a scenario key, and the blueprint in
  // response.blueprint. The single read gives no modules, so the blueprint
  // is needed for the flow
  const response = await __.callApi(`scenarios/${scenarioId}`);
  const blueprint = await __.callApi(`scenarios/${scenarioId}/blueprint`);

  return {
    ...__.formatScenario(response.scenario),
    flow: __.buildFlow(blueprint.response.blueprint.flow),
  };
}

__ = {
  callApi,
  buildFlow,
  formatScenario,
};
