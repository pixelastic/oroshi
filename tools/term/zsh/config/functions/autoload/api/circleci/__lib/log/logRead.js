import { stripVTControlCharacters } from 'node:util';
import { _, pMap } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { parseCircleciUrl } from '../parseCircleciUrl.js';
import { resolveRunId } from '../resolveRunId.js';
import { runRead } from '../run/runRead.js';

export let __;

const V1_BASE_URL = 'https://circleci.com/api/v1.1';

/**
 * Read the Log of one Run: the output of every Step of every Job
 * @param {object} options - What to read and filters
 * @param {string} options.target - URL of a Run or a Job, number of a Job, or id of a Run (a workflow UUID)
 * @param {string} [options.project] - Slug of the Project, needed by a Job number
 * @param {string} [options.job] - Only the Steps of the Job of this name
 * @param {string} [options.status] - Only the Steps of this status, applied before the download
 * @returns {Promise<object>} The Log, with one entry per Step
 */
export async function logRead(options) {
  const { target, project, job, status } = options;

  if (!target) {
    throw firostError(
      'CIRCLECI_MISSING_ARGUMENT',
      'Pass a URL, a job number or the id of a run',
    );
  }

  const { jobNumber, ...source } = __.parseTarget(target, project);
  const runId = await __.resolveRunId({ ...source, jobNumber });
  const run = await __.runRead({ runId });

  // An approval Job has no number, and so no Step. A Job URL or number keeps
  // only its Job
  const jobs = _.filter(
    run.jobs,
    (item) =>
      !_.isNull(item.number) &&
      (!job || item.name === job) &&
      (!jobNumber || item.number === jobNumber),
  );

  const stepsByJob = await pMap(jobs, async (item) => {
    const detail = await __.callApi(`project/${run.project}/${item.number}`, {
      baseUrl: V1_BASE_URL,
    });
    return _.chain(detail.steps)
      .flatMap('actions')
      .filter((step) => !status || step.status === status)
      .map((step) => __.formatStep(item, step))
      .value();
  });

  // Download after the filters, so that a filtered Step costs no request
  const steps = await pMap(_.flatten(stepsByJob), async (step) => {
    const { outputUrl, ...rest } = step;
    return { ...rest, output: await __.readOutput(outputUrl) };
  });

  return {
    id: run.id,
    project: run.project,
    createdAt: run.createdAt,
    steps,
  };
}

__ = {
  /**
   * Tell what the target points to
   * @param {string} target - URL of a Run or a Job, number of a Job, or id of a Run
   * @param {string} [project] - Slug of the Project, needed by a Job number
   * @returns {object} The Slug, the id of the Run and the number of the Job, when the target holds them
   */
  parseTarget(target, project) {
    if (/^https?:\/\//i.test(target)) {
      return parseCircleciUrl(target);
    }
    if (!/^\d+$/.test(target)) {
      return { runId: target };
    }
    if (!project) {
      throw firostError(
        'CIRCLECI_MISSING_ARGUMENT',
        'Pass --project with a job number',
      );
    }
    return { project, jobNumber: Number(target) };
  },
  /**
   * Format one Step of a Job, without its output
   * @param {object} job - The Job of the Step, as formatted by runRead
   * @param {object} step - The Step, as returned by the v1.1 job endpoint
   * @returns {object} The Step, with the URL of its output
   */
  formatStep(job, step) {
    const millis = step.run_time_millis;
    return {
      job: job.name,
      jobNumber: job.number,
      name: step.name,
      status: step.status,
      duration: _.isNil(millis) ? null : Math.round(millis / 1000),
      outputUrl: step.output_url,
    };
  },
  /**
   * Download the output of a Step, without its ANSI codes
   * @param {string} [url] - Presigned URL of the output
   * @returns {Promise<string>} The text of the output, empty without a URL
   */
  async readOutput(url) {
    if (!url) {
      return '';
    }
    const text = await __.downloadOutput(url);
    return stripVTControlCharacters(text);
  },
  /**
   * Download the messages of an output and join their text
   * @param {string} url - Presigned URL of the output, which needs no token
   * @returns {Promise<string>} The text of the output
   */
  async downloadOutput(url) {
    const response = await __.fetch(url);
    if (!response.ok) {
      throw firostError('CIRCLECI_REQUEST_FAILED', `${response.status} ${url}`);
    }
    const messages = await response.json();
    return _.chain(messages).map('message').join('').value();
  },
  resolveRunId,
  runRead,
  callApi,
  fetch,
};
