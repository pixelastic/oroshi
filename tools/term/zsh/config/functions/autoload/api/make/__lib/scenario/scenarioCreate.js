import { resolve } from 'node:path';
import { _ } from 'golgoth';
import { readJson } from 'firost';
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
  const {
    name,
    blueprint,
    blueprintFile,
    scheduling,
    schedulingFile,
    folderId,
  } = options;

  const { teamId } = await __.getConfig();

  const blueprintContent = await __.parseJson({
    inline: blueprint,
    filepath: blueprintFile,
    fallback: {},
  });
  const schedulingContent = await __.parseJson({
    inline: scheduling,
    filepath: schedulingFile,
    fallback: { type: 'on-demand' },
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
  /**
   * Get a JSON value from a file, or inline. The file wins over the inline value
   * @param {object} options - Where the value comes from
   * @param {string|object} [options.inline] - JSON string, or the object itself
   * @param {string} [options.filepath] - Path to a JSON file
   * @param {object} options.fallback - Value when there is neither
   * @returns {Promise<object>} The parsed value
   */
  async parseJson(options) {
    const { inline, filepath, fallback } = options;
    if (filepath) {
      // firost resolves a relative path from its own folder, not from the caller
      return await __.readJson(resolve(filepath));
    }
    return _.isString(inline) ? JSON.parse(inline) : (inline ?? fallback);
  },
  callApi,
  formatScenario,
  getConfig,
  readJson,
};
