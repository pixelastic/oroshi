import { _ } from 'golgoth';
import { firostError } from 'firost';
import { __, baseListRaw } from '../baseListRaw.js';

describe('baseListRaw', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      bases: [
        { id: 'appA', name: 'DevRel' },
        { id: 'appB', name: 'Other' },
        { id: 'appC', name: 'Third' },
      ],
    });
    vi.spyOn(__, 'formatBase').mockImplementation((base) => ({
      ...base,
      name: base.name.toUpperCase(),
    }));
  });

  it('reads the Bases from the schema endpoint', async () => {
    await baseListRaw();

    expect(__.callApi).toHaveBeenCalledWith('meta/bases');
  });

  it('prints one line per formatted Base', async () => {
    const actual = await baseListRaw({ limit: 10 });

    expect(actual).toEqual('appA▮DEVREL\nappB▮OTHER\nappC▮THIRD');
  });

  it.each([
    { title: '25 by default', options: {}, expected: 25 },
    { title: 'the limit that is passed', options: { limit: 2 }, expected: 2 },
  ])('returns at most $title', async ({ options, expected }) => {
    __.callApi.mockReturnValue({
      bases: _.times(30, (index) => ({ id: `app${index}`, name: 'Base' })),
    });
    const actual = await baseListRaw(options);

    expect(actual.split('\n')).toHaveLength(expected);
  });

  it('prints an empty line when no Base is accessible', async () => {
    __.callApi.mockReturnValue({ bases: [] });

    const actual = await baseListRaw();

    expect(actual).toEqual('');
  });

  it('surfaces the failure of the API', async () => {
    __.callApi.mockImplementation(() => {
      throw firostError('AIRTABLE_REQUEST_FAILED', 'Invalid token');
    });

    let actual = null;
    try {
      await baseListRaw();
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'AIRTABLE_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', 'Invalid token');
  });

  describe('toLine', () => {
    it.each([
      {
        title: 'joins the id and the name',
        input: { id: 'appA', name: 'DevRel' },
        expected: 'appA▮DevRel',
      },
      {
        title: 'replaces newlines with a space and removes separators',
        input: { id: 'appA', name: 'Line one\nLine▮two▯three' },
        expected: 'appA▮Line one Linetwothree',
      },
    ])('$title', ({ input, expected }) => {
      const actual = __.toLine(input);

      expect(actual).toEqual(expected);
    });
  });
});
