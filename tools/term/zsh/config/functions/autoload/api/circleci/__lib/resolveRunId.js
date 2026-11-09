import { firostError } from 'firost';
import { callApi } from './callApi.js';

export let __;

/**
 * Find the id of the Run to read
 * @param {object} options - The Run, or one of its Jobs
 * @param {string} [options.runId] - Id of the Run, returned as it is
 * @param {string} [options.project] - Slug of the Project of the Job
 * @param {number} [options.jobNumber] - Number of the Job, resolved to its latest Run
 * @returns {Promise<string>} The id of the Run
 */
export async function resolveRunId(options) {
  const { runId, project, jobNumber } = options;

  if (runId) {
    return runId;
  }

  const job = await __.callApi(`project/${project}/job/${jobNumber}`);
  const id = job.latest_workflow?.id;
  if (!id) {
    throw firostError(
      'CIRCLECI_NOT_FOUND',
      `No run found for the job ${jobNumber} of ${project}`,
    );
  }
  return id;
}

__ = {
  callApi,
};
