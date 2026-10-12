import { resolve } from 'node:path';
import { _ } from 'golgoth';
import { readJson } from 'firost';
import { callApi } from '../callApi.js';
import { formatScenario } from './formatScenario.js';

export let __;

/**
 * Update some fields of one Scenario. The other fields keep their value
 * @param {object} options - Id of the Scenario, and the fields to change
 * @param {number|string} options.scenarioId - Scenario ID
 * @param {string} [options.name] - New name of the Scenario
 * @param {string|object} [options.blueprint] - Blueprint as a JSON string, or the object itself
 * @param {string} [options.blueprintFile] - Path to a JSON file of the Blueprint. Wins over blueprint
 * @param {string|object} [options.scheduling] - Scheduling as a JSON string, or the object itself
 * @param {string} [options.schedulingFile] - Path to a JSON file of the Scheduling. Wins over scheduling
 * @param {number|string} [options.folderId] - Folder ID
 * @returns {Promise<object>} The updated Scenario, formatted
 */
export async function scenarioUpdate(options) {
  const {
    scenarioId,
    name,
    blueprint,
    blueprintFile,
    scheduling,
    schedulingFile,
    folderId,
  } = options;

  const blueprintContent = await __.parseJson({
    inline: blueprint,
    filepath: blueprintFile,
  });
  const schedulingContent = await __.parseJson({
    inline: scheduling,
    filepath: schedulingFile,
  });

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
  return __.formatScenario(response.scenario);
}

__ = {
  /**
   * Get a JSON value from a file, or inline. The file wins over the inline value
   * @param {object} options - Where the value comes from
   * @param {string|object} [options.inline] - JSON string, or the object itself
   * @param {string} [options.filepath] - Path to a JSON file
   * @returns {Promise<object|undefined>} The parsed value, undefined if there is neither
   */
  async parseJson(options) {
    const { inline, filepath } = options;
    if (filepath) {
      // firost resolves a relative path from its own folder, not from the caller
      return await __.readJson(resolve(filepath));
    }
    return _.isString(inline) ? JSON.parse(inline) : inline;
  },
  callApi,
  formatScenario,
  readJson,
};
