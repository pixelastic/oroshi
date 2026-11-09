import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { projectRead } from '../project/projectRead.js';

export let __;

/**
 * Trigger a new Pipeline on a Project of CircleCI
 * @param {object} options - Project and what to run
 * @param {string} options.project - Slug of the Project
 * @param {string} [options.branch] - Branch to run, the default branch of the Project if empty
 * @returns {Promise<object>} The new Pipeline
 */
export async function runTrigger(options) {
  const { project } = options;

  if (!project) {
    throw firostError(
      'CIRCLECI_MISSING_ARGUMENT',
      'Pass the project with --project <slug>',
    );
  }

  // Validate before calling the API, so a typo costs no request
  const parameters = __.parseParameters(options.parameters);

  const branch = options.branch || (await __.readDefaultBranch(project));

  const response = await __.callApi(`project/${project}/pipeline`, {
    method: 'POST',
    body: _.omitBy({ branch, parameters }, _.isUndefined),
  });

  return {
    id: response.id,
    number: response.number,
    state: response.state,
    createdAt: response.created_at,
  };
}

__ = {
  /**
   * Parse the parameters of the Pipeline, passed as a JSON object
   * @param {string} [input] - JSON object, like '{"key": "value"}'
   * @returns {object|undefined} The parameters, with their types, or nothing when none are passed
   */
  parseParameters(input) {
    if (!input) {
      return undefined;
    }

    let parsed = null;
    try {
      parsed = JSON.parse(input);
    } catch {
      // Reported below, like any value that is not an object
    }

    if (!_.isPlainObject(parsed)) {
      throw firostError(
        'CIRCLECI_INVALID_ARGUMENT',
        'Pass --parameters as a JSON object, like \'{"key": "value"}\'',
      );
    }
    return parsed;
  },
  /**
   * Read the default branch of a Project
   * @param {string} project - Slug of the Project
   * @returns {Promise<string>} Name of the default branch
   */
  async readDefaultBranch(project) {
    const { vcs_info } = await __.projectRead({ projectSlug: project });
    return vcs_info.default_branch;
  },
  callApi,
  projectRead,
};
