import { __, scenarioModuleSearch } from '../scenarioModuleSearch.js';

describe('scenarioModuleSearch', () => {
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
                    {
                      flow: [{ id: 3, module: 'airtable:ActionSearchRecords' }],
                    },
                    { flow: [{ id: 4, module: 'slack:CreateMessage' }] },
                  ],
                },
              ],
            },
          },
        };
      }
      return {
        operations: [
          { moduleId: 3, total: 528, warnings: 2, errors: 1 },
          { moduleId: 1, total: 50, warnings: 0, errors: 0 },
          { moduleId: 4, total: 12, warnings: 0, errors: 0 },
        ],
      };
    });
  });

  it('joins the module names of the blueprint with the operations', async () => {
    const actual = await scenarioModuleSearch({ scenarioId: 925, days: 15 });

    expect(actual).toEqual([
      {
        moduleId: 3,
        module: 'airtable:ActionSearchRecords',
        operations: 528,
        warnings: 2,
        errors: 1,
      },
      {
        moduleId: 1,
        module: 'gateway:CustomWebHook',
        operations: 50,
        warnings: 0,
        errors: 0,
      },
      {
        moduleId: 4,
        module: 'slack:CreateMessage',
        operations: 12,
        warnings: 0,
        errors: 0,
      },
    ]);
  });

  it('keeps only the modules of the given app', async () => {
    const actual = await scenarioModuleSearch({
      scenarioId: 925,
      days: 15,
      app: 'airtable',
    });

    expect(actual).toEqual([
      {
        moduleId: 3,
        module: 'airtable:ActionSearchRecords',
        operations: 528,
        warnings: 2,
        errors: 1,
      },
    ]);
  });

  it('passes the number of days to the API', async () => {
    await scenarioModuleSearch({ scenarioId: 925, days: 15 });

    expect(__.callApi).toHaveBeenCalledWith(
      'scenarios/925/modules/operations',
      { query: { days: 15 } },
    );
  });

  it('leaves an unknown module without a name', async () => {
    __.callApi.mockImplementation((path) =>
      path.endsWith('blueprint')
        ? { response: { blueprint: { flow: [] } } }
        : { operations: [{ moduleId: 9, total: 1, warnings: 0, errors: 0 }] },
    );

    const actual = await scenarioModuleSearch({ scenarioId: 925, days: 1 });

    expect(actual).toEqual([
      { moduleId: 9, module: '', operations: 1, warnings: 0, errors: 0 },
    ]);
  });
});

describe('scenarioModuleSearch arguments', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({});
  });

  it.each([
    {
      title: 'MAKE_SCENARIO_ID_MISSING without a Scenario ID',
      input: { days: 15 },
      code: 'MAKE_SCENARIO_ID_MISSING',
      expected:
        'Missing the Scenario ID. Usage: make-scenario-module-list <scenarioId> --days <1-30> [--app <app>]',
    },
    {
      title: 'MAKE_DAYS_OUT_OF_RANGE above 30',
      input: { scenarioId: 925, days: 31 },
      code: 'MAKE_DAYS_OUT_OF_RANGE',
      expected:
        'Invalid --days 31, it must be a whole number from 1 to 30. Usage: make-scenario-module-list <scenarioId> --days <1-30> [--app <app>]',
    },
    {
      title: 'MAKE_DAYS_OUT_OF_RANGE below 1',
      input: { scenarioId: 925, days: 0 },
      code: 'MAKE_DAYS_OUT_OF_RANGE',
      expected:
        'Invalid --days 0, it must be a whole number from 1 to 30. Usage: make-scenario-module-list <scenarioId> --days <1-30> [--app <app>]',
    },
    {
      title: 'MAKE_DAYS_OUT_OF_RANGE when missing',
      input: { scenarioId: 925 },
      code: 'MAKE_DAYS_OUT_OF_RANGE',
      expected:
        'Invalid --days undefined, it must be a whole number from 1 to 30. Usage: make-scenario-module-list <scenarioId> --days <1-30> [--app <app>]',
    },
  ])('$title', async ({ input, code, expected }) => {
    let actual = null;
    try {
      await scenarioModuleSearch(input);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', code);
    expect(actual).toHaveProperty('message', expected);
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
