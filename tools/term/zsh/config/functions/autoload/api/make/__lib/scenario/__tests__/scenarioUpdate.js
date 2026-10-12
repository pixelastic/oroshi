import { resolve } from 'node:path';
import { __, scenarioUpdate } from '../scenarioUpdate.js';

describe('scenarioUpdate', () => {
  const blueprint = { flow: [], metadata: { version: 1 } };
  const scheduling = { type: 'indefinitely', interval: 900 };

  /**
   * Get the body of the first call to the API
   * @returns {object} The body
   */
  function sentBody() {
    const [, { body }] = __.callApi.mock.calls[0];
    return body;
  }

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ scenario: { id: 925 } });
    vi.spyOn(__, 'formatScenario').mockReturnValue({ id: 'formatted' });
    vi.spyOn(__, 'readJson').mockReturnValue({});
  });

  it.each([
    {
      title: 'the name',
      input: { name: 'oroshi-test-b' },
      expected: { name: 'oroshi-test-b' },
    },
    {
      title: 'the folder',
      input: { folderId: 12 },
      expected: { folderId: 12 },
    },
    {
      title: 'the name and the folder',
      input: { name: 'oroshi-test-b', folderId: 12 },
      expected: { name: 'oroshi-test-b', folderId: 12 },
    },
  ])('sends only $title', async ({ input, expected }) => {
    await scenarioUpdate({ scenarioId: 925, ...input });

    expect(sentBody()).toEqual(expected);
  });

  it('calls the endpoint of the scenario id', async () => {
    await scenarioUpdate({ scenarioId: 925, name: 'oroshi-test-b' });

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925', {
      method: 'PATCH',
      body: { name: 'oroshi-test-b' },
    });
  });

  it('serializes the blueprint and the scheduling as JSON strings', async () => {
    await scenarioUpdate({
      scenarioId: 925,
      blueprint: JSON.stringify(blueprint),
      scheduling: JSON.stringify(scheduling),
    });

    expect(sentBody()).toEqual({
      blueprint: JSON.stringify(blueprint),
      scheduling: JSON.stringify(scheduling),
    });
  });

  it('reads the blueprint and the scheduling from their files', async () => {
    __.readJson.mockImplementation((filepath) =>
      filepath === resolve('./blueprint.json') ? blueprint : scheduling,
    );

    await scenarioUpdate({
      scenarioId: 925,
      blueprintFile: './blueprint.json',
      schedulingFile: './scheduling.json',
    });

    expect(sentBody()).toEqual({
      blueprint: JSON.stringify(blueprint),
      scheduling: JSON.stringify(scheduling),
    });
  });

  it('prefers the file version when both are given', async () => {
    __.readJson.mockReturnValue(blueprint);

    await scenarioUpdate({
      scenarioId: 925,
      blueprint: '{"flow":[{"id":1}]}',
      blueprintFile: './blueprint.json',
    });

    expect(sentBody()).toEqual({ blueprint: JSON.stringify(blueprint) });
  });

  it('returns the updated scenario, formatted', async () => {
    const expected = { id: 'formatted' };

    const actual = await scenarioUpdate({ scenarioId: 925, name: 'a' });

    expect(__.formatScenario).toHaveBeenCalledWith({ id: 925 });
    expect(actual).toEqual(expected);
  });
});
