import { __, scenarioRun } from '../scenarioRun.js';

describe('scenarioRun', () => {
  const data = { email: 'tim@example.com' };

  /**
   * Get the body of the first call to the API
   * @returns {object} The body
   */
  function sentBody() {
    const [, { body }] = __.callApi.mock.calls[0];
    return body;
  }

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ executionId: 'abc123' });
    vi.spyOn(__, 'getJsonFromOptions').mockReturnValue(undefined);
  });

  it('calls the run endpoint of the Scenario id', async () => {
    await scenarioRun({ scenarioId: 925 });

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925/run', {
      method: 'POST',
      body: {},
    });
  });

  it('sends the data got from the options', async () => {
    __.getJsonFromOptions.mockReturnValue(data);
    const options = { scenarioId: 925, data: 'a', dataFile: 'b' };

    await scenarioRun(options);

    expect(__.getJsonFromOptions).toHaveBeenCalledWith(options, 'data');
    expect(sentBody()).toEqual({ data });
  });

  it('returns the execution ID without --wait', async () => {
    const actual = await scenarioRun({ scenarioId: 925 });

    expect(sentBody()).toEqual({});
    expect(actual).toEqual('abc123');
  });

  it('asks for a responsive run with --wait, and returns the whole response', async () => {
    const response = {
      executionId: 'abc123',
      status: 1,
      outputs: { greeting: 'hello' },
    };
    __.callApi.mockReturnValue(response);

    const actual = await scenarioRun({ scenarioId: 925, wait: true });

    expect(sentBody()).toEqual({ responsive: true });
    expect(actual).toEqual(response);
  });
});
