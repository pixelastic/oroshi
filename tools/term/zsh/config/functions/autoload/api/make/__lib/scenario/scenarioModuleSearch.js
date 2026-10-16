import { _ } from 'golgoth';
import { firostError } from 'firost';
import { assertScenarioId } from '../assertScenarioId.js';
import { callApi } from '../callApi.js';

export let __;

const USAGE =
  'make-scenario-module-list <scenarioId> --days <1-30> [--app <app>]';
const MIN_DAYS = 1;
const MAX_DAYS = 30;

/**
 * Search the Modules of a Scenario with their operations over the last days
 * @param {object} options - Search options
 * @param {number|string} options.scenarioId - Scenario ID
 * @param {number} options.days - Number of days to count, from 1 to 30
 * @param {string} [options.app] - Only the Modules of this app, such as airtable
 * @returns {Promise<object[]>} One entry per Module with moduleId, module, operations, warnings and errors
 */
export async function scenarioModuleSearch(options) {
  const { scenarioId, days, app } = options;

  // Check the arguments before calling the API, so a typo costs no request
  assertScenarioId(scenarioId, USAGE);
  if (!_.isInteger(days) || !_.inRange(days, MIN_DAYS, MAX_DAYS + 1)) {
    throw firostError(
      'MAKE_DAYS_OUT_OF_RANGE',
      `Invalid --days ${days}, it must be a whole number from ${MIN_DAYS} to ${MAX_DAYS}. Usage: ${USAGE}`,
    );
  }

  // The blueprint knows the names of the Modules, the operations endpoint
  // knows their counts
  const blueprint = await __.callApi(`scenarios/${scenarioId}/blueprint`);
  const operations = await __.callApi(
    `scenarios/${scenarioId}/modules/operations`,
    { query: { days } },
  );
  const names = __.moduleNames(blueprint.response.blueprint.flow);

  return _.chain(operations.operations)
    .map((entry) => ({
      moduleId: entry.moduleId,
      module: names[entry.moduleId] || '',
      operations: entry.total,
      warnings: entry.warnings,
      errors: entry.errors,
    }))
    .filter((entry) => !app || _.startsWith(entry.module, `${app}:`))
    .value();
}

__ = {
  /**
   * Map the id of every Module of a flow to its name, routes included
   * @param {object[]} flow - The flow of a blueprint, or of a route
   * @returns {object} The module name, such as airtable:ActionSearchRecords, by module id
   */
  moduleNames(flow) {
    return _.reduce(
      flow,
      (names, blueprintModule) => ({
        ...names,
        [blueprintModule.id]: blueprintModule.module,
        ..._.reduce(
          blueprintModule.routes,
          (routeNames, route) => ({
            ...routeNames,
            ...__.moduleNames(route.flow),
          }),
          {},
        ),
      }),
      {},
    );
  },
  callApi,
};
