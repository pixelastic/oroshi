import { callApi } from '../callApi.js';

export let __;

/**
 * Delete one Scenario of the Team
 * @param {object} options - Id of the Scenario
 * @param {number|string} options.scenarioId - Scenario ID
 * @returns {Promise<number|string>} The ID of the removed Scenario
 */
export async function scenarioDelete(options) {
  const { scenarioId } = options;

  await __.callApi(`scenarios/${scenarioId}`, { method: 'DELETE' });
  return scenarioId;
}

__ = {
  callApi,
};
