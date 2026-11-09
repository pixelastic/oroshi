import { _, pMap } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { defaultLimit } from '../defaultLimit.js';
import { toLimit } from '../toLimit.js';
import { formatRun } from './formatRun.js';

export let __;

/**
 * Search the Runs of a Project, newest first
 * @param {object} options - Anchor and filters
 * @param {string} options.project - Slug of the Project, the anchor
 * @param {string} [options.branch] - Only the Runs of this branch
 * @param {string} [options.status] - Only the Runs of this status, applied after the limit
 * @param {number|string} [options.limit] - Maximum number of Runs, before the status filter
 * @returns {Promise<object[]>} The Runs, formatted, without their Jobs
 */
export async function runSearch(options) {
  const { project, branch, status, limit = defaultLimit } = options;

  if (!project) {
    throw firostError(
      'CIRCLECI_MISSING_ARGUMENT',
      'Pass the project with --project <slug>',
    );
  }

  // Validate before calling the API, so a typo costs no request
  const max = toLimit(limit);

  const entries = await __.listEntries({ project, branch, max });

  // CircleCI has no status filter: keep the status after the limit
  return _.chain(entries)
    .take(max)
    .map(({ workflow, pipeline }) => __.formatRun({ workflow, pipeline }))
    .map((run) => _.omit(run, 'jobs'))
    .filter((run) => !status || run.status === status)
    .value();
}

__ = {
  /**
   * Read the pipelines page by page, and the workflows of each pipeline,
   * until there are enough workflows or no more pipelines
   * @param {object} options - What to read
   * @param {string} options.project - Slug of the Project
   * @param {string} [options.branch] - Only the pipelines of this branch
   * @param {number} options.max - Number of workflows wanted
   * @returns {Promise<object[]>} Each workflow with its pipeline, newest first
   */
  async listEntries({ project, branch, max }) {
    const entries = [];
    let pageToken;
    do {
      const query = _.omitBy(
        { branch, 'page-token': pageToken },
        _.isUndefined,
      );
      const page = await __.callApi(`project/${project}/pipeline`, { query });

      // One pipeline at a time, to stop reading as soon as there are enough
      await pMap(
        page.items,
        async (pipeline) => {
          if (entries.length >= max) {
            return;
          }
          const workflows = await __.callApi(
            `pipeline/${pipeline.id}/workflow`,
          );
          _.each(workflows.items, (workflow) => {
            entries.push({ workflow, pipeline });
          });
        },
        { concurrency: 1 },
      );

      pageToken = page.next_page_token;
    } while (pageToken && entries.length < max);

    return entries;
  },
  callApi,
  formatRun,
};
