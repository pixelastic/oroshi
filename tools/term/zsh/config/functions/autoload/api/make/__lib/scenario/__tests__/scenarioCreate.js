import { resolve } from 'node:path';
import { __, scenarioCreate } from '../scenarioCreate.js';

describe('scenarioCreate', () => {
  const blueprint = { flow: [], metadata: { version: 1 } };
  const scheduling = { type: 'indefinitely', interval: 900 };

  /**
   * Get the body of the first call to the API, with the JSON strings parsed
   * @returns {object} The body, with a parsed blueprint and scheduling
   */
  function sentBody() {
    const [, { body }] = __.callApi.mock.calls[0];
    return {
      ...body,
      blueprint: JSON.parse(body.blueprint),
      scheduling: JSON.parse(body.scheduling),
    };
  }

  beforeEach(() => {
    vi.spyOn(__, 'getConfig').mockReturnValue({ teamId: '215' });
    vi.spyOn(__, 'callApi').mockReturnValue({ scenario: { id: 925 } });
    vi.spyOn(__, 'formatScenario').mockReturnValue({ id: 'formatted' });
    vi.spyOn(__, 'readJson').mockReturnValue({});
  });

  it('sends the team, the name and the folder', async () => {
    await scenarioCreate({
      name: 'oroshi-test-a',
      blueprint: JSON.stringify(blueprint),
      folderId: 12,
    });

    expect(__.callApi).toHaveBeenCalledWith('scenarios', {
      method: 'POST',
      body: expect.objectContaining({ teamId: 215, folderId: 12 }),
    });
    // Make reads the name of the Scenario from its Blueprint
    expect(sentBody().blueprint).toEqual({
      ...blueprint,
      name: 'oroshi-test-a',
    });
  });

  it('serializes the blueprint and the scheduling as JSON strings', async () => {
    await scenarioCreate({
      blueprint: JSON.stringify(blueprint),
      scheduling: JSON.stringify(scheduling),
    });

    const { body } = __.callApi.mock.calls[0][1];
    expect(body).toHaveProperty('blueprint', JSON.stringify(blueprint));
    expect(body).toHaveProperty('scheduling', JSON.stringify(scheduling));
  });

  it('schedules on-demand by default', async () => {
    await scenarioCreate({ blueprint: JSON.stringify(blueprint) });

    expect(sentBody().scheduling).toEqual({ type: 'on-demand' });
  });

  it('reads the blueprint and the scheduling from their files', async () => {
    __.readJson.mockImplementation((filepath) =>
      filepath === resolve('./blueprint.json') ? blueprint : scheduling,
    );

    await scenarioCreate({
      blueprintFile: './blueprint.json',
      schedulingFile: './scheduling.json',
    });

    expect(sentBody()).toEqual({
      teamId: 215,
      blueprint,
      scheduling,
    });
  });

  it('resolves a relative file path from the working directory', async () => {
    await scenarioCreate({ blueprintFile: './blueprint.json' });

    expect(__.readJson).toHaveBeenCalledWith(resolve('./blueprint.json'));
  });

  it('prefers the file version when both are given', async () => {
    __.readJson.mockImplementation((filepath) =>
      filepath === resolve('./blueprint.json') ? blueprint : scheduling,
    );

    await scenarioCreate({
      blueprint: '{"flow":[{"id":1}]}',
      blueprintFile: './blueprint.json',
      scheduling: '{"type":"on-demand"}',
      schedulingFile: './scheduling.json',
    });

    expect(sentBody()).toEqual({
      teamId: 215,
      blueprint,
      scheduling,
    });
  });

  it('returns the created scenario, formatted', async () => {
    const actual = await scenarioCreate({
      blueprint: JSON.stringify(blueprint),
    });

    expect(__.formatScenario).toHaveBeenCalledWith({ id: 925 });
    expect(actual).toEqual({ id: 'formatted' });
  });
});
