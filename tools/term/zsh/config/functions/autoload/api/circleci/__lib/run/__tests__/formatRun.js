import { formatRun } from '../formatRun.js';

describe('formatRun', () => {
  const workflow = {
    id: 'runA',
    name: 'commit',
    status: 'failed',
    project_slug: 'gh/pixelastic/firost',
    pipeline_number: 2113,
    created_at: '2026-11-05T19:56:08.513Z',
    stopped_at: '2026-11-05T19:57:33.867Z',
  };
  const pipeline = {
    vcs: {
      revision: 'c93ae76c8605ec58602db0e5049c7887818f4145',
      branch: 'renovate/tooling',
    },
  };
  const job = {
    job_number: 2111,
    name: 'ci',
    status: 'failed',
    type: 'build',
    started_at: '2026-11-05T19:56:10.51Z',
    stopped_at: '2026-11-05T19:57:33.867Z',
  };

  it('returns the run with its jobs', () => {
    const actual = formatRun({ workflow, pipeline, jobs: [job] });

    expect(actual).toEqual({
      id: 'runA',
      project: 'gh/pixelastic/firost',
      name: 'commit',
      status: 'failed',
      branch: 'renovate/tooling',
      commit: 'c93ae76',
      pipelineNumber: 2113,
      createdAt: '2026-11-05T19:56:08.513Z',
      duration: 85,
      url: 'https://app.circleci.com/pipelines/gh/pixelastic/firost/2113/workflows/runA',
      jobs: [
        {
          number: 2111,
          name: 'ci',
          status: 'failed',
          type: 'build',
          duration: 83,
          url: 'https://app.circleci.com/pipelines/gh/pixelastic/firost/2113/workflows/runA/jobs/2111',
        },
      ],
    });
  });

  it('has a null duration while the run is running', () => {
    const running = { ...workflow, status: 'running', stopped_at: null };

    const actual = formatRun({ workflow: running, pipeline, jobs: [] });

    expect(actual.duration).toBeNull();
  });

  it('has a null duration for a job without stopped_at', () => {
    const running = { ...job, status: 'running', stopped_at: undefined };

    const actual = formatRun({ workflow, pipeline, jobs: [running] });

    expect(actual.jobs[0].duration).toBeNull();
  });

  it('has a null number and a null url for an approval job', () => {
    const approval = {
      name: 'hold',
      status: 'on_hold',
      type: 'approval',
    };

    const actual = formatRun({ workflow, pipeline, jobs: [approval] });

    expect(actual).toHaveProperty('jobs.0', {
      number: null,
      name: 'hold',
      status: 'on_hold',
      type: 'approval',
      duration: null,
      url: null,
    });
  });
});
