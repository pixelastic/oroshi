import { __, executionTiming } from '../executionTiming.js';

const START = '2026-10-16T10:00:00.000Z';
const execution = { id: 'exec', timestamp: START, duration: 10000 };

/**
 * Build a log entry of a module
 * @param {string} executionId - Execution of the entry
 * @param {number} seconds - Seconds after the start of the Execution
 * @param {number} bundles - Number of bundles
 * @returns {object} A module log entry
 */
function entry(executionId, seconds, bundles = 1) {
  const timestamp = new Date(Date.parse(START) + seconds * 1000).toISOString();
  return { executionId, timestamp, bundles };
}

describe('executionTiming', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockImplementation((path) => {
      if (path === 'scenarios/925/blueprint') {
        return {
          response: {
            blueprint: {
              flow: [
                { id: 1, module: 'gateway:CustomWebHook' },
                {
                  id: 2,
                  module: 'builtin:BasicRouter',
                  routes: [
                    { flow: [{ id: 3, module: 'airtable:ActionSearch' }] },
                    { flow: [{ id: 4, module: 'slack:CreateMessage' }] },
                  ],
                },
              ],
            },
          },
        };
      }
      const logs = {
        'scenarios/925/modules/1/logs': [entry('exec', 1)],
        'scenarios/925/modules/2/logs': [entry('exec', 2)],
        'scenarios/925/modules/3/logs': [
          entry('other', 20),
          entry('exec', 10, 3),
        ],
        'scenarios/925/modules/4/logs': [entry('other', 20)],
      };
      return { moduleLogs: logs[path] };
    });
  });

  it('gives each executed module its bundle count and duration', async () => {
    const actual = await executionTiming({ scenarioId: 925, execution });

    expect(actual).toHaveProperty('0', {
      id: 1,
      module: 'gateway:CustomWebHook',
      bundleCount: 1,
      durationMs: 1000,
      durationPercent: 10,
    });
    expect(actual[1]).toMatchObject({
      id: 2,
      bundleCount: 1,
      durationMs: 1000,
      durationPercent: 10,
    });
  });

  it('starts the first module at the start of the Execution', async () => {
    const actual = await executionTiming({ scenarioId: 925, execution });

    expect(actual).toHaveProperty('0.durationMs', 1000);
  });

  it('measures a module from the previous entry, routes included', async () => {
    const actual = await executionTiming({ scenarioId: 925, execution });

    expect(actual).toHaveProperty('1.routes.0.flow.0', {
      id: 3,
      module: 'airtable:ActionSearch',
      bundleCount: 3,
      durationMs: 8000,
      durationPercent: 80,
    });
  });

  it('leaves a module without entry untouched', async () => {
    const actual = await executionTiming({ scenarioId: 925, execution });

    expect(actual).toHaveProperty('1.routes.1.flow.0', {
      id: 4,
      module: 'slack:CreateMessage',
    });
  });

  it('reads at most 50 entries per page', async () => {
    await executionTiming({ scenarioId: 925, execution });

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925/modules/1/logs', {
      query: { 'pg[limit]': 50, 'pg[offset]': 0 },
    });
  });
});

describe('executionTiming paging', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockImplementation((path, options) => {
      if (path === 'scenarios/925/blueprint') {
        return {
          response: {
            blueprint: { flow: [{ id: 1, module: 'gateway:CustomWebHook' }] },
          },
        };
      }
      const offset = options.query['pg[offset]'];
      // Two full pages of recent entries, then the Execution, then older ones
      const pages = {
        0: Array.from({ length: 50 }, () => entry('other', 100)),
        50: [
          ...Array.from({ length: 49 }, () => entry('other', 50)),
          entry('exec', 4),
        ],
        100: [...Array.from({ length: 50 }, () => entry('old', -100))],
        150: [entry('never', -200)],
      };
      return { moduleLogs: pages[offset] };
    });
  });

  it('reads the next page until entries are older than the Execution', async () => {
    const actual = await executionTiming({ scenarioId: 925, execution });

    expect(actual).toHaveProperty('0.durationMs', 4000);
    // The blueprint and three pages, the fourth page is not read
    expect(__.callApi).toHaveBeenCalledTimes(4);
  });
});

describe('executionTiming failure', () => {
  it('fails when a module cannot be read', async () => {
    vi.spyOn(__, 'callApi').mockImplementation((path) => {
      if (path === 'scenarios/925/blueprint') {
        return {
          response: {
            blueprint: { flow: [{ id: 1, module: 'gateway:CustomWebHook' }] },
          },
        };
      }
      throw new Error('429');
    });

    let actual = null;
    try {
      await executionTiming({ scenarioId: 925, execution });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', '429');
  });
});
