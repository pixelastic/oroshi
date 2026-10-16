import { __, folderRead } from '../folderRead.js';

describe('folderRead', () => {
  // The Folders of the API, by parent. An empty key is the top level. As the
  // API does, a listing nests the direct subfolders of every Folder it returns
  const tree = {
    '': [
      {
        id: 1,
        name: 'parent',
        parentId: null,
        hasChildren: true,
        children: [{ id: 2, name: 'child', parentId: 1, hasChildren: true }],
      },
      {
        id: 9,
        name: 'other',
        parentId: null,
        hasChildren: false,
        children: [],
      },
    ],
    1: [
      {
        id: 2,
        name: 'child',
        parentId: 1,
        hasChildren: true,
        children: [{ id: 3, name: 'grandchild', parentId: 2 }],
      },
    ],
    2: [
      {
        id: 3,
        name: 'grandchild',
        parentId: 2,
        hasChildren: false,
        children: [],
      },
    ],
    3: [],
  };

  beforeEach(() => {
    vi.spyOn(__, 'getConfig').mockReturnValue({
      key: 'secret-key',
      teamId: '42',
      zone: 'eu2',
    });
    vi.spyOn(__, 'callApi').mockImplementation((_path, { query }) => ({
      scenariosFolders: tree[query.parentId ?? ''],
    }));
    vi.spyOn(__, 'scenarioSearch').mockReturnValue({
      results: [{ id: 100, name: 'Sync', folderId: 2 }],
      hasMore: false,
    });
  });

  it.each([
    {
      title: 'returns the main fields of the Folder',
      input: { folderId: 2 },
      expected: { id: 2, name: 'child', parentId: 1 },
    },
    {
      title: 'finds a Folder of the top level',
      input: { folderId: 9 },
      expected: { id: 9, name: 'other' },
    },
    {
      title: 'finds a Folder nested deeper than its first subfolders',
      input: { folderId: 3 },
      expected: { id: 3, parentId: 2 },
    },
    {
      title: 'accepts the id as a string',
      input: { folderId: '2' },
      expected: { id: 2 },
    },
    {
      title: 'returns its direct subfolders only',
      input: { folderId: 2 },
      expected: {
        subfolders: [
          { id: 3, name: 'grandchild', parentId: 2, hasChildren: false },
        ],
      },
    },
    {
      title: 'returns its direct scenarios',
      input: { folderId: 2 },
      expected: { scenarios: [{ id: 100, name: 'Sync', folderId: 2 }] },
    },
  ])('$title', async ({ input, expected }) => {
    const actual = await folderRead(input);

    expect(actual).toEqual(expect.objectContaining(expected));
  });

  it('formats the Folder and each of its subfolders', async () => {
    vi.spyOn(__, 'formatFolder').mockImplementation((folder) => ({
      ...folder,
      formatted: true,
    }));

    const actual = await folderRead({ folderId: 2 });

    expect(actual).toHaveProperty('formatted', true);
    expect(actual).toHaveProperty('subfolders', [
      expect.objectContaining({ formatted: true }),
    ]);
  });

  it('asks for the scenarios of this Folder only, with no limit', async () => {
    await folderRead({ folderId: 2 });

    expect(__.scenarioSearch).toHaveBeenCalledTimes(1);
    expect(__.scenarioSearch).toHaveBeenCalledWith({
      folderId: 2,
      limit: Infinity,
    });
  });

  it('fails when no Folder has this id', async () => {
    let actual = null;
    try {
      await folderRead({ folderId: 404 });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'MAKE_FOLDER_NOT_FOUND');
  });

  it('lets the error of callApi reach the caller', async () => {
    __.callApi.mockImplementation(() => {
      throw new Error('MAKE_REQUEST_FAILED');
    });

    let actual = null;
    try {
      await folderRead({ folderId: 2 });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'MAKE_REQUEST_FAILED');
  });
});
