import { resolve } from 'node:path';
import { _ } from 'golgoth';
import { readJson } from 'firost';
import { callApi } from '../callApi.js';

export let __;

/**
 * Run one Scenario of the Team. The Scenario must be enabled
 * @param {object} options - Id of the Scenario, and how to run it
 * @param {number|string} options.scenarioId - Scenario ID
 * @param {string|object} [options.data] - Inputs as a JSON string, or the object itself
 * @param {string} [options.dataFile] - Path to a JSON file of the inputs. Wins over data
 * @param {boolean} [options.wait] - Wait for the end of the execution (40 seconds at most)
 * @returns {Promise<string|object>} The execution ID, or with wait the response holding status and outputs
 */
export async function scenarioRun(options) {
  const { scenarioId, data, dataFile, wait } = options;

  const dataContent = await __.parseJson({
    inline: data,
    filepath: dataFile,
  });

  // Keep only the given keys, so a missing data or responsive is not sent
  const body = _.omitBy(
    {
      data: dataContent,
      responsive: wait ? true : undefined,
    },
    _.isUndefined,
  );
  const response = await __.callApi(`scenarios/${scenarioId}/run`, {
    method: 'POST',
    body,
  });

  return wait ? response : response.executionId;
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
  readJson,
};
