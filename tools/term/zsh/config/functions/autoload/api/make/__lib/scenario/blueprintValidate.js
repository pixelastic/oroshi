import { _ } from 'golgoth';
import { listModules } from './listModules.js';

export let __;

/**
 * Check a blueprint locally, with no request. Make has no validate endpoint
 * It checks that module IDs are unique across the whole flow, that every
 * module has a module and a version, and that every field required by
 * metadata.expect has its key in mapper or parameters. The value of a key is
 * not checked, and neither is the type of a connection
 * It cannot detect an unsupported expression, such as a regex literal in replace
 * @param {object} blueprint - The blueprint to check
 * @returns {string[]} The problems, empty when the blueprint is valid
 */
export function blueprintValidate(blueprint) {
  const modules = listModules(blueprint.flow);
  return [
    ...__.findDuplicateIds(modules),
    ..._.flatMap(modules, __.findModuleProblems),
  ];
}

__ = {
  /**
   * Report each module ID that more than one module uses
   * @param {object[]} modules - Every module of the flow
   * @returns {string[]} One problem per duplicated ID
   */
  findDuplicateIds(modules) {
    return _.chain(modules)
      .countBy('id')
      .pickBy((count) => count > 1)
      .keys()
      .map((id) => `Module ID ${id} is used more than once`)
      .value();
  },

  /**
   * Report the missing module, version and required fields of one module
   * @param {object} blueprintModule - Module to check
   * @returns {string[]} The problems of the module
   */
  findModuleProblems(blueprintModule) {
    const { id, module, version } = blueprintModule;
    const problems = [];
    if (!module) {
      problems.push(`Module ${id} has no module`);
    }
    if (!version) {
      problems.push(`Module ${id} has no version`);
    }
    const missingFields = _.chain(blueprintModule.metadata?.expect)
      .filter('required')
      .map('name')
      .reject(
        (name) =>
          _.has(blueprintModule.mapper, [name]) ||
          _.has(blueprintModule.parameters, [name]),
      )
      .map((name) => `Module ${id} (${module}) has no required field ${name}`)
      .value();
    return [...problems, ...missingFields];
  },
};
