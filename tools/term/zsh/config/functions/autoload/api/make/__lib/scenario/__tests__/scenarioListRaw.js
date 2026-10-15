import { __, scenarioListRaw } from '../scenarioListRaw.js';

describe('scenarioListRaw', () => {
  beforeEach(() => {
    vi.spyOn(__, 'scenarioSearchPaged').mockReturnValue({
      scenarios: [
        {
          id: 925,
          name: 'Sync',
          isActive: true,
          folderId: 12,
          lastEdit: '2026-02-26T13:17:47.779Z',
        },
        { id: 926, name: 'Backup', isActive: false, folderId: null },
      ],
      hasMore: false,
    });
    vi.spyOn(__, 'warnMoreResults').mockReturnValue();
  });

  it('searches with the flags it received', async () => {
    await scenarioListRaw({ query: 'sync', limit: 10 });

    expect(__.scenarioSearchPaged).toHaveBeenCalledWith({
      query: 'sync',
      limit: 10,
    });
  });

  it('prints one line per Scenario, with the id first', async () => {
    const actual = await scenarioListRaw({});

    expect(actual).toEqual(
      '925▮Sync▮true▮12▮2026-02-26T13:17:47.779Z\n926▮Backup▮false▮▮',
    );
  });

  it('prints an empty line for no Scenario', async () => {
    __.scenarioSearchPaged.mockReturnValue({ scenarios: [], hasMore: false });

    const actual = await scenarioListRaw({});

    expect(actual).toEqual('');
  });

  it('warns that more results exist, and still prints the lines', async () => {
    __.scenarioSearchPaged.mockReturnValue({
      scenarios: [{ id: 925, name: 'Sync' }],
      hasMore: true,
    });

    const actual = await scenarioListRaw({});

    expect(__.warnMoreResults).toHaveBeenCalledTimes(1);
    expect(actual).toEqual('925▮Sync▮▮▮');
  });

  it('does not warn when no more results exist', async () => {
    await scenarioListRaw({});

    expect(__.warnMoreResults).not.toHaveBeenCalled();
  });

  describe('toLine', () => {
    it.each([
      {
        title: 'separates the columns with ▮',
        input: { id: 1, name: 'Sync', isActive: true, folderId: 2 },
        expected: '1▮Sync▮true▮2▮',
      },
      {
        title: 'removes separators and newlines from the name',
        input: { id: 1, name: 'Line one\nLine▮two▯three', isActive: false },
        expected: '1▮Line one Linetwothree▮false▮▮',
      },
    ])('$title', ({ input, expected }) => {
      const actual = __.toLine(input);

      expect(actual).toEqual(expected);
    });
  });
});
