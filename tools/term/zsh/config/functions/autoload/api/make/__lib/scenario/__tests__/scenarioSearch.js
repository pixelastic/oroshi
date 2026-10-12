import { __, scenarioSearch } from '../scenarioSearch.js';

describe('scenarioSearch', () => {
  beforeEach(() => {
    vi.spyOn(__, 'getConfig').mockReturnValue({
      key: 'secret-key',
      teamId: '42',
      zone: 'eu2',
    });
    vi.spyOn(__, 'callApi').mockReturnValue({
      scenarios: [{ id: 1 }, { id: 2 }],
    });
    vi.spyOn(__, 'formatScenario').mockImplementation((scenario) => ({
      id: scenario.id,
      formatted: true,
    }));
  });

  it('sends the team of the configuration', async () => {
    await scenarioSearch({ query: 'sync' });

    expect(__.callApi).toHaveBeenCalledWith('scenarios', {
      query: expect.objectContaining({ teamId: '42' }),
    });
  });

  it('sends the text as search', async () => {
    await scenarioSearch({ query: 'sync' });

    const { query } = __.callApi.mock.calls[0][1];
    expect(query).toHaveProperty('search', 'sync');
  });

  it.each([
    {
      title: 'the Folder ID as folderId',
      input: { folderId: 12 },
      expected: 12,
    },
    { title: 'no folderId by default', input: {}, expected: undefined },
  ])('sends $title', async ({ input, expected }) => {
    await scenarioSearch(input);

    const { query } = __.callApi.mock.calls[0][1];
    expect(query).toHaveProperty('folderId', expected);
  });

  it.each([
    { title: 'the limit as pg[limit]', input: { limit: 10 }, expected: 10 },
    { title: '25 by default', input: {}, expected: 25 },
  ])('sends $title', async ({ input, expected }) => {
    await scenarioSearch({ query: 'sync', ...input });

    const { query } = __.callApi.mock.calls[0][1];
    expect(query).toHaveProperty(['pg[limit]'], expected);
  });

  it('returns the scenarios, formatted', async () => {
    const actual = await scenarioSearch({ query: 'sync' });

    expect(actual).toEqual([
      { id: 1, formatted: true },
      { id: 2, formatted: true },
    ]);
  });
});
