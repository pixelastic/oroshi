import { __, scenarioModuleListRaw } from '../scenarioModuleListRaw.js';

describe('scenarioModuleListRaw', () => {
  beforeEach(() => {
    vi.spyOn(__, 'scenarioModuleSearch').mockReturnValue([
      {
        moduleId: 3,
        module: 'airtable:ActionSearchRecords',
        operations: 528,
        warnings: 2,
        errors: 1,
      },
      { moduleId: 9, module: '', operations: 1, warnings: 0, errors: 0 },
    ]);
  });

  it('passes the options to the search', async () => {
    await scenarioModuleListRaw({ scenarioId: 925, days: 15, app: 'airtable' });

    expect(__.scenarioModuleSearch).toHaveBeenCalledWith({
      scenarioId: 925,
      days: 15,
      app: 'airtable',
    });
  });

  it('returns one line per module, with ▮ between the fields', async () => {
    const actual = await scenarioModuleListRaw({ scenarioId: 925, days: 15 });

    expect(actual).toEqual('3▮airtable:ActionSearchRecords▮528▮2▮1\n9▮▮1▮0▮0');
  });
});
