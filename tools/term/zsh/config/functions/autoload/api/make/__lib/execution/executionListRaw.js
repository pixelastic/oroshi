import { _ } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { executionSearch } from './executionSearch.js';

export let __;

/**
 * List the Executions of a Scenario as raw lines, one per Execution
 * @param {object} options - Same options as search
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function executionListRaw(options) {
  // Ask search for the Executions, with the flags we received
  const executions = await __.executionSearch(options);

  return _.chain(executions)
    .map((execution) => __.toLine(execution))
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one Execution into a raw line
   * @param {object} execution - Execution, as returned by search
   * @returns {string} The id, status code, type, timestamp, duration and operations, separated by ▮
   */
  toLine(execution) {
    const { id, status, type, timestamp, duration, operations } = execution;
    return _.chain([id, status, type, timestamp, duration, operations])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },
  executionSearch,
};
