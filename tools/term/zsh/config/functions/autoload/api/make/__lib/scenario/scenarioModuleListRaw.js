import { _ } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { scenarioModuleSearch } from './scenarioModuleSearch.js';

export let __;

/**
 * List the Modules of a Scenario as raw lines, one per Module
 * @param {object} options - Same options as search
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function scenarioModuleListRaw(options) {
  const modules = await __.scenarioModuleSearch(options);

  return _.chain(modules)
    .map((entry) => __.toLine(entry))
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one Module into a raw line
   * @param {object} entry - Module, as returned by search
   * @returns {string} The module id, name, operations, warnings and errors, separated by ▮
   */
  toLine(entry) {
    const { moduleId, module, operations, warnings, errors } = entry;
    return _.chain([moduleId, module, operations, warnings, errors])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },
  scenarioModuleSearch,
};
