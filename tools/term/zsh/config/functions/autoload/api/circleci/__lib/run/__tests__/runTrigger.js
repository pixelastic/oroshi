import { firostError } from 'firost';
import { __, runTrigger } from '../runTrigger.js';

describe('runTrigger', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      id: 'pipelineA',
      number: 25,
      state: 'created',
      created_at: '2019-08-24T14:15:22Z',
    });
  });

  it('sends a POST to the pipeline endpoint of the project, on the branch', async () => {
    await runTrigger({ project: 'gh/pixelastic/firost', branch: 'main' });

    expect(__.callApi).toHaveBeenCalledWith(
      'project/gh/pixelastic/firost/pipeline',
      {
        method: 'POST',
        body: { branch: 'main' },
      },
    );
  });

  it('returns the new pipeline', async () => {
    const actual = await runTrigger({
      project: 'gh/pixelastic/firost',
      branch: 'main',
    });

    expect(actual).toEqual({
      id: 'pipelineA',
      number: 25,
      state: 'created',
      createdAt: '2019-08-24T14:15:22Z',
    });
  });

  it('runs the default branch of the project when none is passed', async () => {
    vi.spyOn(__, 'projectRead').mockReturnValue({
      vcs_info: { default_branch: 'master' },
    });

    await runTrigger({ project: 'gh/pixelastic/firost' });

    expect(__.projectRead).toHaveBeenCalledWith({
      projectSlug: 'gh/pixelastic/firost',
    });
    expect(__.callApi).toHaveBeenCalledWith(
      'project/gh/pixelastic/firost/pipeline',
      {
        method: 'POST',
        body: { branch: 'master' },
      },
    );
  });

  it('sends the parameters with their types', async () => {
    await runTrigger({
      project: 'gh/pixelastic/firost',
      branch: 'main',
      parameters: '{"deploy_prod": true, "count": 3, "name": "a=b"}',
    });

    expect(__.callApi).toHaveBeenCalledWith(
      'project/gh/pixelastic/firost/pipeline',
      {
        method: 'POST',
        body: {
          branch: 'main',
          parameters: { deploy_prod: true, count: 3, name: 'a=b' },
        },
      },
    );
  });

  it.each([
    { title: 'not JSON', input: '{deploy_prod' },
    { title: 'an array', input: '[1]' },
    { title: 'a string', input: '"a"' },
    { title: 'null', input: 'null' },
  ])('throws when the parameters are $title', async ({ input }) => {
    let actual = null;
    try {
      await runTrigger({
        project: 'gh/pixelastic/firost',
        branch: 'main',
        parameters: input,
      });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_INVALID_ARGUMENT');
    expect(actual).toHaveProperty(
      'message',
      'Pass --parameters as a JSON object, like \'{"key": "value"}\'',
    );
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('lets a failed call through as a request error', async () => {
    __.callApi.mockImplementation(() => {
      throw firostError('CIRCLECI_REQUEST_FAILED', '404 Not found');
    });

    let actual = null;
    try {
      await runTrigger({ project: 'gh/pixelastic/firost', branch: 'main' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_REQUEST_FAILED');
  });

  it.each([
    { title: 'empty', input: '' },
    { title: 'missing', input: undefined },
  ])('throws when the project is $title', async ({ input }) => {
    let actual = null;
    try {
      await runTrigger({ project: input, branch: 'main' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_MISSING_ARGUMENT');
    expect(actual).toHaveProperty(
      'message',
      'Pass the project with --project <slug>',
    );
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
