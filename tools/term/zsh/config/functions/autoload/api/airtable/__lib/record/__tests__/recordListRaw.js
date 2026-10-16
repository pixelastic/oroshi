import { __, recordListRaw } from '../recordListRaw.js';

describe('recordListRaw', () => {
  const anchors = { baseId: 'appDEVREL', tableId: 'tblMEETUPS' };

  beforeEach(() => {
    vi.spyOn(__, 'recordSearch').mockReturnValue({
      results: [
        { id: 'recA', fields: { Name: 'Paris Meetup' } },
        { id: 'recB', fields: {} },
      ],
      hasMore: false,
    });
    vi.spyOn(console, 'error').mockReturnValue();
  });

  it('searches with the formula and the flags it received', async () => {
    await recordListRaw({ ...anchors, limit: 10, query: "{Name}='Paris'" });

    expect(__.recordSearch).toHaveBeenCalledWith({
      ...anchors,
      limit: 10,
      query: "{Name}='Paris'",
    });
  });

  it('prints one line per Record', async () => {
    const actual = await recordListRaw(anchors);

    expect(actual).toEqual('recA▮{"Name":"Paris Meetup"}\nrecB▮{}');
  });

  it('prints an empty line for a Table without Records', async () => {
    __.recordSearch.mockReturnValue({ results: [], hasMore: false });

    const actual = await recordListRaw(anchors);

    expect(actual).toEqual('');
  });

  it('warns that more results exist, and still prints the lines', async () => {
    __.recordSearch.mockReturnValue({
      results: [{ id: 'recA', fields: {} }],
      hasMore: true,
    });

    const actual = await recordListRaw(anchors);

    expect(console.error).toHaveBeenCalledWith(
      'More results exist, raise --limit',
    );
    expect(actual).toEqual('recA▮{}');
  });

  it('does not warn when no more results exist', async () => {
    await recordListRaw(anchors);

    expect(console.error).not.toHaveBeenCalled();
  });

  describe('toLine', () => {
    it.each([
      {
        title: 'joins the id and the Fields as JSON',
        input: { id: 'recA', fields: { Name: 'Paris', Seats: 80 } },
        expected: 'recA▮{"Name":"Paris","Seats":80}',
      },
      {
        title: 'removes separators and newlines from the values',
        input: { id: 'recA', fields: { Name: 'Line one\nLine▮two▯three' } },
        expected: 'recA▮{"Name":"Line one\\nLinetwothree"}',
      },
    ])('$title', ({ input, expected }) => {
      const actual = __.toLine(input);

      expect(actual).toEqual(expected);
    });
  });
});
