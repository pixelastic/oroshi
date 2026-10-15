import { __, scenarioSearchPaged } from '../scenarioSearchPaged.js';

describe('scenarioSearchPaged', () => {
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
    await scenarioSearchPaged({ query: 'sync' });

    expect(__.callApi).toHaveBeenCalledWith('scenarios', {
      query: expect.objectContaining({ teamId: '42' }),
    });
  });

  it('sends the text as search', async () => {
    await scenarioSearchPaged({ query: 'sync' });

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
    await scenarioSearchPaged(input);

    const { query } = __.callApi.mock.calls[0][1];
    expect(query).toHaveProperty('folderId', expected);
  });

  it.each([
    {
      title: 'the limit plus one as pg[limit]',
      input: { limit: 10 },
      expected: 11,
    },
    { title: '26 by default', input: {}, expected: 26 },
  ])('sends $title', async ({ input, expected }) => {
    await scenarioSearchPaged({ query: 'sync', ...input });

    const { query } = __.callApi.mock.calls[0][1];
    expect(query).toHaveProperty(['pg[limit]'], expected);
    expect(query).toHaveProperty(['pg[offset]'], 0);
  });

  it('asks for pages of 10 000 at most', async () => {
    await scenarioSearchPaged({ limit: 50000 });

    const { query } = __.callApi.mock.calls[0][1];
    expect(query).toHaveProperty(['pg[limit]'], 10000);
  });

  it.each([
    {
      title: 'all Scenarios, with hasMore false when all arrived',
      input: {},
      expected: {
        scenarios: [
          { id: 1, formatted: true },
          { id: 2, formatted: true },
        ],
        hasMore: false,
      },
    },
    {
      title: 'no more than the limit, with hasMore true when more exist',
      input: { limit: 1 },
      expected: { scenarios: [{ id: 1, formatted: true }], hasMore: true },
    },
  ])('returns $title', async ({ input, expected }) => {
    const actual = await scenarioSearchPaged({ query: 'sync', ...input });

    expect(actual).toEqual(expected);
  });
});
