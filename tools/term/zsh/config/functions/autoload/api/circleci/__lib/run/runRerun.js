import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { runRead } from './runRead.js';

export let __;

/**
 * Rerun every Job of one Run of CircleCI
 * @param {object} options - Id of the Run
 * @param {string} options.runId - Id of the Run (a workflow UUID)
 * @returns {Promise<object>} The new Run, formatted
 */
export async function runRerun(options) {
  const { runId } = options;

  if (!runId) {
    throw firostError('CIRCLECI_MISSING_ARGUMENT', 'Pass the id of the run');
  }

  // An empty body keeps the default of CircleCI: rerun every job
  const response = await __.callApi(`workflow/${runId}/rerun`, {
    method: 'POST',
    body: {},
  });

  // CircleCI starts a new workflow, which is the run to print
  return await __.runRead({ runId: response.workflow_id });
}

__ = {
  callApi,
  runRead,
};
