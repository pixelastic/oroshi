import { _ } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { scenarioSearch } from './scenarioSearch.js';

export let __;

/**
 * List the Scenarios of the Team as raw lines, one per Scenario
 * @param {object} options - Same options as search
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function scenarioListRaw(options) {
  // Ask search for the Scenarios, with the flags we received
  const scenarios = await __.scenarioSearch(options);

  return _.chain(scenarios)
    .map((scenario) => __.toLine(scenario))
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one Scenario into a raw line
   * @param {object} scenario - Scenario, as returned by search
   * @returns {string} The id, name, state, Folder id and last edit, separated by ▮
   */
  toLine(scenario) {
    const { id, name, isActive, folderId, lastEdit } = scenario;
    return _.chain([id, name, isActive, folderId, lastEdit])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },
  scenarioSearch,
};
