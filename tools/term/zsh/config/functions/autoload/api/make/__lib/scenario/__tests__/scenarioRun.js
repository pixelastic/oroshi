import { resolve } from 'node:path';
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
    vi.spyOn(__, 'readJson').mockReturnValue({});
  });

  it('calls the run endpoint of the Scenario id', async () => {
    await scenarioRun({ scenarioId: 925 });

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925/run', {
      method: 'POST',
      body: {},
    });
  });

  it('sends the data given by --data', async () => {
    await scenarioRun({ scenarioId: 925, data: JSON.stringify(data) });

    expect(sentBody()).toEqual({ data });
  });

  it('reads the data from --data-file', async () => {
    __.readJson.mockReturnValue(data);

    await scenarioRun({ scenarioId: 925, dataFile: './data.json' });

    expect(__.readJson).toHaveBeenCalledWith(resolve('./data.json'));
    expect(sentBody()).toEqual({ data });
  });

  it('prefers the file version when both are given', async () => {
    __.readJson.mockReturnValue(data);

    await scenarioRun({
      scenarioId: 925,
      data: '{"email":"other"}',
      dataFile: './data.json',
    });

    expect(sentBody()).toEqual({ data });
  });

  it('returns the execution ID without --wait', async () => {
    const actual = await scenarioRun({ scenarioId: 925 });

    expect(sentBody()).toEqual({});
    expect(actual).toEqual('abc123');
  });

  it('asks for a responsive run with --wait, and returns the outputs', async () => {
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
