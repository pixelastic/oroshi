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

  /**
   * Make getJsonFromOptions return the given contents by key
   * @param {object} contents - The JSON values, by key
   */
  function mockContents(contents) {
    __.getJsonFromOptions.mockImplementation((_options, key) => contents[key]);
  }

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockImplementation((path) => {
      if (path === 'scenarios/925/blueprint') {
        return { response: { blueprint: { flow: [{ id: 2 }] } } };
      }
      return { scenario: { id: 925 } };
    });
    vi.spyOn(__, 'formatScenario').mockReturnValue({
      id: 'formatted',
      isinvalid: false,
    });
    vi.spyOn(__, 'buildFlow').mockReturnValue([{ id: 'flow' }]);
    vi.spyOn(__, 'blueprintAlign').mockImplementation((input) => ({
      ...input,
      aligned: true,
    }));
    vi.spyOn(__, 'getJsonFromOptions').mockReturnValue(undefined);
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
    mockContents({ blueprint, scheduling });

    await scenarioUpdate({ scenarioId: 925 });

    expect(sentBody()).toEqual({
      blueprint: JSON.stringify({ ...blueprint, aligned: true }),
      scheduling: JSON.stringify(scheduling),
    });
  });

  it('sends an aligned blueprint', async () => {
    mockContents({ blueprint });

    await scenarioUpdate({ scenarioId: 925 });

    expect(__.blueprintAlign).toHaveBeenCalledWith(blueprint);
    expect(JSON.parse(sentBody().blueprint)).toHaveProperty('aligned', true);
  });

  it('skips the alignment when it sends no blueprint', async () => {
    await scenarioUpdate({ scenarioId: 925, name: 'a' });

    expect(__.blueprintAlign).not.toHaveBeenCalled();
    expect(sentBody()).toEqual({ name: 'a' });
  });

  it('gets the blueprint and the scheduling from the options', async () => {
    const options = { scenarioId: 925, blueprintFile: 'a', scheduling: 'b' };

    await scenarioUpdate(options);

    expect(__.getJsonFromOptions).toHaveBeenCalledWith(options, 'blueprint');
    expect(__.getJsonFromOptions).toHaveBeenCalledWith(options, 'scheduling');
  });

  it('returns the updated scenario, formatted, with the flow it sent', async () => {
    mockContents({ blueprint: { flow: [{ id: 1 }] } });

    const actual = await scenarioUpdate({ scenarioId: 925 });

    expect(__.formatScenario).toHaveBeenCalledWith({ id: 925 });
    expect(__.buildFlow).toHaveBeenCalledWith([{ id: 1 }]);
    expect(__.callApi).toHaveBeenCalledTimes(1);
    expect(actual).toEqual({
      id: 'formatted',
      isinvalid: false,
      flow: [{ id: 'flow' }],
    });
  });

  it('prints isinvalid of the updated scenario', async () => {
    __.formatScenario.mockReturnValue({ id: 'formatted', isinvalid: true });

    const actual = await scenarioUpdate({ scenarioId: 925, name: 'a' });

    expect(actual).toHaveProperty('isinvalid', true);
  });

  it('reads the blueprint of the scenario when only the name changes', async () => {
    const actual = await scenarioUpdate({ scenarioId: 925, name: 'a' });

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925/blueprint');
    expect(__.buildFlow).toHaveBeenCalledWith([{ id: 2 }]);
    expect(actual).toHaveProperty('flow', [{ id: 'flow' }]);
  });
});
