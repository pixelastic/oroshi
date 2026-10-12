import { __, folderListRaw } from '../folderListRaw.js';

describe('folderListRaw', () => {
  beforeEach(() => {
    vi.spyOn(__, 'folderSearch').mockReturnValue([
      {
        id: 399268,
        name: 'publishing',
        path: 'publishing',
        parentId: null,
        scenariosTotal: 6,
        hasChildren: false,
      },
      {
        id: 539242,
        name: 'child',
        path: 'parent/child',
        parentId: 539241,
        scenariosTotal: 0,
        hasChildren: true,
      },
    ]);
  });

  it('searches with the flags it received', async () => {
    await folderListRaw({ limit: 10 });

    expect(__.folderSearch).toHaveBeenCalledWith({ limit: 10 });
  });

  it('prints one line per Folder, with the id first', async () => {
    const actual = await folderListRaw({});

    expect(actual).toEqual(
      '399268▮publishing▮publishing▮▮6\n539242▮child▮parent/child▮539241▮0',
    );
  });

  it('prints an empty line for no Folder', async () => {
    __.folderSearch.mockReturnValue([]);

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
