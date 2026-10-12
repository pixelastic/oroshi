import { __, folderListRaw } from '../folderListRaw.js';

describe('folderListRaw', () => {
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
      name: `folder ${folder.id}`,
      path: `path/${folder.id}`,
      parentId: null,
      scenariosTotal: folder.id,
    }));
  });

  it('sends the team of the configuration', async () => {
    await folderListRaw();

    expect(__.callApi).toHaveBeenCalledWith('scenarios-folders', {
      query: expect.objectContaining({ teamId: '42' }),
    });
  });

  it.each([
    { title: 'the limit as pg[limit]', input: { limit: 10 }, expected: 10 },
    { title: '25 by default', input: {}, expected: 25 },
  ])('sends $title', async ({ input, expected }) => {
    await folderListRaw(input);

    const { query } = __.callApi.mock.calls[0][1];
    expect(query).toHaveProperty(['pg[limit]'], expected);
  });

  it.each([
    {
      title: 'prints no more lines than the limit, as the API ignores it',
      input: { limit: 2 },
      expected: '1▮folder 1▮path/1▮▮1\n2▮folder 2▮path/2▮▮2',
    },
    {
      title: 'prints one line per Folder, with the id first',
      input: {},
      expected:
        '1▮folder 1▮path/1▮▮1\n2▮folder 2▮path/2▮▮2\n3▮folder 3▮path/3▮▮3',
    },
  ])('$title', async ({ input, expected }) => {
    const actual = await folderListRaw(input);

    expect(actual).toEqual(expected);
  });

  it('prints the id, name, path, parent id and Scenario count of a Folder', async () => {
    __.callApi.mockReturnValue({ scenariosFolders: [{ id: 539242 }] });
    __.formatFolder.mockReturnValue({
      id: 539242,
      name: 'child',
      path: 'parent/child',
      parentId: 539241,
      scenariosTotal: 0,
      hasChildren: true,
    });

    const actual = await folderListRaw({});

    expect(actual).toEqual('539242▮child▮parent/child▮539241▮0');
  });

  it('prints an empty line for no Folder', async () => {
    __.callApi.mockReturnValue({ scenariosFolders: [] });

    const actual = await folderListRaw({});

    expect(actual).toEqual('');
  });

  describe('toLine', () => {
    it.each([
      {
        title: 'separates the columns with ▮',
        input: { id: 1, name: 'Sync', path: 'Sync', scenariosTotal: 3 },
        expected: '1▮Sync▮Sync▮▮3',
      },
      {
        title: 'removes separators and newlines from the name',
        input: { id: 1, name: 'Line one\nLine▮two▯three', path: 'a' },
        expected: '1▮Line one Linetwothree▮a▮▮',
      },
    ])('$title', ({ input, expected }) => {
      const actual = __.toLine(input);

      expect(actual).toEqual(expected);
    });
  });
});
