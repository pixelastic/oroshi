import { executionSearchPaged } from './executionSearchPaged.js';

export let __;

/**
 * Search the Executions of a Scenario, newest first
 * @param {object} options - Same options as the paged search
 * @returns {Promise<object[]>} The Executions, formatted
 */
export async function executionSearch(options) {
  const { executions } = await __.executionSearchPaged(options);
  return executions;
}

__ = {
  executionSearchPaged,
};
