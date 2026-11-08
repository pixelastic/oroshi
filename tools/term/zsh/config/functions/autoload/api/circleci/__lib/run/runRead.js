import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { formatRun } from './formatRun.js';

export let __;

/**
 * Read one Run of CircleCI, with its Jobs
 * @param {object} options - Id of the Run
 * @param {string} options.runId - Id of the Run (a workflow UUID)
 * @returns {Promise<object>} The Run, formatted
 */
export async function runRead(options) {
  const { runId } = options;

  if (!runId) {
    throw firostError('CIRCLECI_MISSING_ARGUMENT', 'Pass the id of the run');
  }

  // The workflow gives the pipeline, which holds the branch and the commit
  const workflow = await __.callApi(`workflow/${runId}`);
  const pipeline = await __.callApi(`pipeline/${workflow.pipeline_id}`);
  const jobs = await __.callApi(`workflow/${runId}/job`);

  return __.formatRun({ workflow, pipeline, jobs: jobs.items });
}

__ = {
  callApi,
  formatRun,
};
