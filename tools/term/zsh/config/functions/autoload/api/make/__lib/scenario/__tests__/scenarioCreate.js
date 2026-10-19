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
    vi.spyOn(__, 'formatScenario').mockReturnValue({
      id: 'formatted',
      isinvalid: false,
    });
    vi.spyOn(__, 'buildFlow').mockReturnValue([{ id: 'flow' }]);
    vi.spyOn(__, 'blueprintAlign').mockImplementation((input) => ({
      ...input,
      aligned: true,
    }));
    vi.spyOn(__, 'blueprintValidate').mockReturnValue([]);
    // The helper gets each JSON value from the options by its key
    const contents = { blueprint, scheduling };
    vi.spyOn(__, 'getJsonFromOptions').mockImplementation(
      (_options, key) => contents[key],
    );
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
      aligned: true,
    });
  });

  it('serializes the blueprint and the scheduling as JSON strings', async () => {
    await scenarioCreate({
      blueprint: JSON.stringify(blueprint),
      scheduling: JSON.stringify(scheduling),
    });

    const { body } = __.callApi.mock.calls[0][1];
    expect(body).toHaveProperty(
      'blueprint',
      JSON.stringify({ ...blueprint, aligned: true }),
    );
    expect(body).toHaveProperty('scheduling', JSON.stringify(scheduling));
  });

  it('sends an aligned blueprint', async () => {
    await scenarioCreate({ name: 'oroshi-test-a', blueprint: 'a' });

    expect(__.blueprintAlign).toHaveBeenCalledWith({
      ...blueprint,
      name: 'oroshi-test-a',
    });
    expect(sentBody().blueprint).toHaveProperty('aligned', true);
  });

  it('validates the blueprint before it aligns it', async () => {
    await scenarioCreate({ name: 'oroshi-test-a', blueprint: 'a' });

    expect(__.blueprintValidate).toHaveBeenCalledWith(blueprint);
    expect(__.blueprintValidate.mock.invocationCallOrder[0]).toBeLessThan(
      __.blueprintAlign.mock.invocationCallOrder[0],
    );
  });

  it('throws the list of problems and sends no request when the blueprint is invalid', async () => {
    __.blueprintValidate.mockReturnValue([
      'Module 1 has no version',
      'Module ID 2 is used more than once',
    ]);

    let actual = null;
    try {
      await scenarioCreate({ blueprint: 'a' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'MAKE_BLUEPRINT_INVALID');
    expect(actual).toHaveProperty(
      'message',
      'Module 1 has no version\nModule ID 2 is used more than once',
    );
    expect(__.blueprintAlign).not.toHaveBeenCalled();
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('gets the blueprint and the scheduling from the options', async () => {
    const options = { blueprint: 'a', blueprintFile: 'b', scheduling: 'c' };

    await scenarioCreate(options);

    expect(__.getJsonFromOptions).toHaveBeenCalledWith(
      options,
      'blueprint',
      {},
    );
    expect(__.getJsonFromOptions).toHaveBeenCalledWith(options, 'scheduling', {
      type: 'on-demand',
    });
  });

  it('returns the created scenario, formatted, with its flow', async () => {
    const flowBlueprint = { flow: [{ id: 1 }] };
    __.getJsonFromOptions.mockImplementation((_options, key) =>
      key === 'blueprint' ? flowBlueprint : scheduling,
    );

    const actual = await scenarioCreate({ blueprint: 'a' });

    expect(__.formatScenario).toHaveBeenCalledWith({ id: 925 });
    // The flow comes from the blueprint that was sent, with no second call
    expect(__.buildFlow).toHaveBeenCalledWith([{ id: 1 }]);
    expect(__.callApi).toHaveBeenCalledTimes(1);
    expect(actual).toEqual({
      id: 'formatted',
      isinvalid: false,
      flow: [{ id: 'flow' }],
    });
  });

  describe('when Make marks the created scenario as invalid', () => {
    let actual = null;
    beforeEach(async () => {
      __.callApi.mockReturnValue({ scenario: { id: 925, isinvalid: true } });

      actual = null;
      try {
        await scenarioCreate({ blueprint: 'a' });
      } catch (error) {
        actual = error;
      }
    });

    it('throws MAKE_BLUEPRINT_INVALID with the ID of the new scenario', () => {
      expect(actual).toHaveProperty('code', 'MAKE_BLUEPRINT_INVALID');
      expect(actual).toHaveProperty(
        'message',
        'Make marked the new Scenario 925 as invalid',
      );
    });

    it('sends no other request, no delete and no repair', () => {
      expect(__.callApi).toHaveBeenCalledTimes(1);
      expect(__.callApi).toHaveBeenCalledWith('scenarios', expect.any(Object));
      expect(__.callApi.mock.calls[0][1]).toHaveProperty('method', 'POST');
    });
  });

  it('lets an error of Make on the request pass through unchanged', async () => {
    const makeError = new Error('400 {"code":"IM007"}');
    makeError.code = 'MAKE_REQUEST_FAILED';
    __.callApi.mockImplementation(() => {
      throw makeError;
    });

    let actual = null;
    try {
      await scenarioCreate({ blueprint: 'a' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toBe(makeError);
  });

  it('prints the created scenario when it is valid', async () => {
    __.callApi.mockReturnValue({ scenario: { id: 925, isinvalid: false } });

    const actual = await scenarioCreate({ blueprint: 'a' });

    expect(actual).toHaveProperty('id', 'formatted');
    expect(actual).toHaveProperty('isinvalid', false);
  });
});
