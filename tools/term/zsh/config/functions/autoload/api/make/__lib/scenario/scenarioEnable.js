import { callApi } from '../callApi.js';
import { scenarioRead } from './scenarioRead.js';

export let __;

/**
 * Enable one Scenario of the Team, so it runs on its Scheduling
 * @param {object} options - Id of the Scenario
 * @param {number|string} options.scenarioId - Scenario ID
 * @returns {Promise<object>} The Scenario, formatted
 */
export async function scenarioEnable(options) {
  const { scenarioId } = options;

  await __.callApi(`scenarios/${scenarioId}/start`, { method: 'POST' });

  // The API answers only the id and the state, so read the full Scenario
  return await __.scenarioRead({ scenarioId });
}

__ = {
  callApi,
  scenarioRead,
};
