import { _ } from 'golgoth';

/**
 * List every module of a flow, including routes and error handlers
 * @param {object[]} flow - Modules to list
 * @returns {object[]} Flat list of modules
 */
export function listModules(flow) {
  return _.flatMap(flow, (blueprintModule) => [
    blueprintModule,
    ...listModules(_.flatMap(blueprintModule.routes, 'flow')),
    ...listModules(blueprintModule.onerror),
  ]);
}
