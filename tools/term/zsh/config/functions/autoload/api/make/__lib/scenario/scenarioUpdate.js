import { _ } from 'golgoth';
import { getJsonFromOptions } from '@oroshi/api-shared/getJsonFromOptions.js';
import { callApi } from '../callApi.js';
import { blueprintAlign } from './blueprintAlign.js';
import { buildFlow } from './buildFlow.js';
import { formatScenario } from './formatScenario.js';

export let __;

/**
 * Update some fields of one Scenario. The other fields keep their value
 * A Blueprint that is sent is aligned on one baseline, left to right, with no
 * way to skip it
 * @param {object} options - Id of the Scenario, and the fields to change
 * @param {number|string} options.scenarioId - Scenario ID
 * @param {string} [options.name] - New name of the Scenario
 * @param {string|object} [options.blueprint] - Blueprint as a JSON string, or the object itself
 * @param {string} [options.blueprintFile] - Path to a JSON file of the Blueprint. Wins over blueprint
 * @param {string|object} [options.scheduling] - Scheduling as a JSON string, or the object itself
 * @param {string} [options.schedulingFile] - Path to a JSON file of the Scheduling. Wins over scheduling
 * @param {number|string} [options.folderId] - Folder ID
 * @returns {Promise<object>} The updated Scenario, formatted, with its flow
 */
export async function scenarioUpdate(options) {
  const { scenarioId, name, folderId } = options;

  const givenBlueprint = await __.getJsonFromOptions(options, 'blueprint');
  // The alignment applies to every Blueprint that is sent, and only to those
  const blueprintContent = givenBlueprint
    ? __.blueprintAlign(givenBlueprint)
    : undefined;
  const schedulingContent = await __.getJsonFromOptions(options, 'scheduling');

  // PATCH leaves the fields that are not given untouched
  const body = _.omitBy(
    {
      name,
      folderId,
      // Make expects the Blueprint and the Scheduling as JSON strings
      // JSON.stringify(undefined) is undefined, so a missing one is not sent
      blueprint: JSON.stringify(blueprintContent),
      scheduling: JSON.stringify(schedulingContent),
    },
    _.isUndefined,
  );
  const response = await __.callApi(`scenarios/${scenarioId}`, {
    method: 'PATCH',
    body,
  });

  // Use the Blueprint that was sent to avoid a second call. Without one, read
  // it like scenarioRead does
  const flow = blueprintContent
    ? blueprintContent.flow
    : (await __.callApi(`scenarios/${scenarioId}/blueprint`)).response.blueprint
        .flow;

  return {
    ...__.formatScenario(response.scenario),
    flow: __.buildFlow(flow),
  };
}

__ = {
  callApi,
  getJsonFromOptions,
  blueprintAlign,
  buildFlow,
  formatScenario,
};
