import { _, dayjs } from 'golgoth';

export let __;

const APP_URL = 'https://app.circleci.com/pipelines';
const COMMIT_LENGTH = 7;

/**
 * Format one Run, built from its workflow, its pipeline and its jobs
 * @param {object} response - What the API returned for the Run
 * @param {object} response.workflow - The workflow of the Run
 * @param {object} response.pipeline - The pipeline of the Run
 * @param {object[]} response.jobs - The jobs of the workflow
 * @returns {object} The Run, with its Jobs
 */
export function formatRun(response) {
  const { workflow, pipeline, jobs } = response;
  const { project_slug, pipeline_number, id } = workflow;
  const url = `${APP_URL}/${project_slug}/${pipeline_number}/workflows/${id}`;

  return {
    id,
    project: project_slug,
    name: workflow.name,
    status: workflow.status,
    branch: pipeline.vcs?.branch,
    commit: _.truncate(pipeline.vcs?.revision, {
      length: COMMIT_LENGTH,
      omission: '',
    }),
    pipelineNumber: pipeline_number,
    createdAt: workflow.created_at,
    duration: __.toDuration(workflow.created_at, workflow.stopped_at),
    url,
    jobs: _.map(jobs, (job) => __.formatJob(job, url)),
  };
}

__ = {
  /**
   * Number of whole seconds between two timestamps
   * @param {string} start - ISO start of the Run or the Job
   * @param {string} [stop] - ISO stop, missing while it is running
   * @returns {number|null} The duration, or null while it is running
   */
  toDuration(start, stop) {
    if (!start || !stop) {
      return null;
    }
    return Math.round(dayjs(stop).diff(start, 'second', true));
  },
  /**
   * Format one Job of a Run
   * @param {object} job - The Job, as returned by the API
   * @param {string} runUrl - URL of its Run
   * @returns {object} The Job, with its duration and its URL
   */
  formatJob(job, runUrl) {
    const number = job.job_number ?? null;
    return {
      number,
      name: job.name,
      status: job.status,
      type: job.type,
      duration: __.toDuration(job.started_at, job.stopped_at),
      // An approval Job has no number, and no page of its own
      url: _.isNull(number) ? null : `${runUrl}/jobs/${number}`,
    };
  },
};
