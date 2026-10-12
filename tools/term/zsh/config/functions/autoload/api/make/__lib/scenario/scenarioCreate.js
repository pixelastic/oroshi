import { getJsonFromOptions } from '@oroshi/api-shared/getJsonFromOptions.js';
import { callApi } from '../callApi.js';
import { getConfig } from '../getConfig.js';
import { formatScenario } from './formatScenario.js';

export let __;

/**
 * Create one Scenario in the Team
 * @param {object} options - Content of the Scenario
 * @param {string} [options.name] - Name of the Scenario
 * @param {string|object} [options.blueprint] - Blueprint as a JSON string, or the object itself
 * @param {string} [options.blueprintFile] - Path to a JSON file of the Blueprint. Wins over blueprint
 * @param {string|object} [options.scheduling] - Scheduling as a JSON string, or the object itself. on-demand by default
 * @param {string} [options.schedulingFile] - Path to a JSON file of the Scheduling. Wins over scheduling
 * @param {number|string} [options.folderId] - Folder ID
 * @returns {Promise<object>} The new Scenario, formatted
 */
export async function scenarioCreate(options) {
  const { name, folderId } = options;

  const { teamId } = await __.getConfig();

  const blueprintContent = await __.getJsonFromOptions(
    options,
    'blueprint',
    {},
  );
  const schedulingContent = await __.getJsonFromOptions(options, 'scheduling', {
    type: 'on-demand',
  });

  // Make reads the name of the Scenario from its Blueprint, and ignores the body
  const namedBlueprint = name
    ? { ...blueprintContent, name }
    : blueprintContent;

  // Make expects the Blueprint and the Scheduling as JSON strings
  const response = await __.callApi('scenarios', {
    method: 'POST',
    body: {
      teamId: Number(teamId),
      folderId,
      blueprint: JSON.stringify(namedBlueprint),
      scheduling: JSON.stringify(schedulingContent),
    },
  });
  return __.formatScenario(response.scenario);
}

__ = {
  callApi,
  getJsonFromOptions,
  formatScenario,
  getConfig,
};
