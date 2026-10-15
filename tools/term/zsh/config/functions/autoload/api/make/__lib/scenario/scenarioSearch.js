import { scenarioSearchPaged } from './scenarioSearchPaged.js';

export let __;

/**
 * Search the Scenarios of the Team by name
 * @param {object} [options] - Same options as the paged search
 * @returns {Promise<object[]>} The Scenarios, formatted
 */
export async function scenarioSearch(options = {}) {
  const { scenarios } = await __.scenarioSearchPaged(options);
  return scenarios;
}

__ = {
  scenarioSearchPaged,
};
