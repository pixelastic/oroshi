import { __, folderSearch } from '../folderSearch.js';

describe('folderSearch', () => {
  beforeEach(() => {
    vi.spyOn(__, 'getConfig').mockReturnValue({
      key: 'secret-key',
      teamId: '42',
      zone: 'eu2',
    });
    vi.spyOn(__, 'callApi').mockReturnValue({
      scenariosFolders: [{ id: 1 }, { id: 2 }, { id: 3 }],
    });
    vi.spyOn(__, 'formatFolder').mockImplementation((folder) => ({
      id: folder.id,
      formatted: true,
    }));
  });

  it('sends the team of the configuration', async () => {
    await folderSearch();

    expect(__.callApi).toHaveBeenCalledWith('scenarios-folders', {
      query: expect.objectContaining({ teamId: '42' }),
    });
  });

  it.each([
    { title: 'the limit as pg[limit]', input: { limit: 10 }, expected: 10 },
    { title: '25 by default', input: {}, expected: 25 },
  ])('sends $title', async ({ input, expected }) => {
    await folderSearch(input);

    const { query } = __.callApi.mock.calls[0][1];
    expect(query).toHaveProperty(['pg[limit]'], expected);
  });

  it.each([
    {
      title: 'returns no more Folders than the limit, as the API ignores it',
      input: { limit: 2 },
      expected: [
        { id: 1, formatted: true },
        { id: 2, formatted: true },
      ],
    },
    {
      title: 'returns the Folders, formatted',
      input: {},
      expected: [
        { id: 1, formatted: true },
        { id: 2, formatted: true },
        { id: 3, formatted: true },
      ],
    },
  ])('$title', async ({ input, expected }) => {
    const actual = await folderSearch(input);

    expect(actual).toEqual(expected);
  });
});
