import { __, recordListRaw } from '../recordListRaw.js';

describe('recordListRaw', () => {
  const anchors = { baseId: 'appDEVREL', tableId: 'tblMEETUPS' };

  beforeEach(() => {
    vi.spyOn(__, 'recordSearch').mockReturnValue([
      { id: 'recA', fields: { Name: 'Paris Meetup' } },
      { id: 'recB', fields: {} },
    ]);
  });

  it('searches with an empty formula and the flags it received', async () => {
    await recordListRaw({ ...anchors, limit: 10 });

    expect(__.recordSearch).toHaveBeenCalledWith({
      ...anchors,
      limit: 10,
      query: '',
    });
  });

  it('prints one line per Record', async () => {
    const actual = await recordListRaw(anchors);

    expect(actual).toEqual('recA▮{"Name":"Paris Meetup"}\nrecB▮{}');
  });

  it('prints an empty line for a Table without Records', async () => {
    __.recordSearch.mockReturnValue([]);

    const actual = await recordListRaw(anchors);

    expect(actual).toEqual('');
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
