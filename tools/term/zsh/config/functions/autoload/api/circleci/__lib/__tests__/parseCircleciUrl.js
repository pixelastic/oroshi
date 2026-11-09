import { parseCircleciUrl } from '../parseCircleciUrl.js';

describe('parseCircleciUrl', () => {
  const runId = '1bd4f068-b2f0-4769-8574-609c4e00ae6c';

  it.each([
    {
      title: 'the GitHub status URL',
      url: 'https://circleci.com/gh/pixelastic/firost/2111',
      expected: { project: 'gh/pixelastic/firost', jobNumber: 2111 },
    },
    {
      title: 'the job URL',
      url: 'https://app.circleci.com/jobs/github/pixelastic/firost/2111',
      expected: { project: 'gh/pixelastic/firost', jobNumber: 2111 },
    },
    {
      title: 'the run URL',
      url: `https://app.circleci.com/pipelines/github/pixelastic/firost/2113/workflows/${runId}`,
      expected: { project: 'gh/pixelastic/firost', runId },
    },
    {
      title: 'the run URL with a job',
      url: `https://app.circleci.com/pipelines/github/pixelastic/firost/2113/workflows/${runId}/jobs/2111`,
      expected: { project: 'gh/pixelastic/firost', runId, jobNumber: 2111 },
    },
    {
      title: 'a URL with a trailing slash',
      url: 'https://circleci.com/gh/pixelastic/firost/2111/',
      expected: { project: 'gh/pixelastic/firost', jobNumber: 2111 },
    },
  ])('parses $title', ({ url, expected }) => {
    const actual = parseCircleciUrl(url);

    expect(actual).toEqual(expected);
  });

  it.each([
    { vcs: 'github', expected: 'gh/org/repo' },
    { vcs: 'gh', expected: 'gh/org/repo' },
    { vcs: 'bitbucket', expected: 'bb/org/repo' },
    { vcs: 'bb', expected: 'bb/org/repo' },
  ])('maps the VCS name $vcs to the slug $expected', ({ vcs, expected }) => {
    const actual = parseCircleciUrl(
      `https://app.circleci.com/jobs/${vcs}/org/repo/12`,
    );

    expect(actual).toHaveProperty('project', expected);
  });

  it.each([
    {
      title: 'another host',
      url: 'https://github.com/pixelastic/firost/pull/12',
    },
    {
      title: 'a CircleCI URL with no recognizable ids',
      url: 'https://app.circleci.com/pipelines/github/pixelastic/firost',
    },
    {
      title: 'a pipeline URL without a run',
      url: 'https://app.circleci.com/pipelines/github/pixelastic/firost/2113',
    },
    {
      title: 'an unknown VCS name',
      url: 'https://circleci.com/svn/pixelastic/firost/2111',
    },
    { title: 'a text that is not a URL', url: 'not a url' },
  ])('throws on $title', ({ url }) => {
    let actual = null;
    try {
      parseCircleciUrl(url);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_INVALID_ARGUMENT');
    expect(actual).toHaveProperty(
      'message',
      `Not a CircleCI run or job URL: ${url}`,
    );
  });
});
