import { _ } from 'golgoth';
import { firostError } from 'firost';
import { __, tableListRaw } from '../tableListRaw.js';

describe('tableListRaw', () => {
  const separators = { field: '▮', list: '▯' };

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      tables: [
        { id: 'tblA', name: 'Meetups' },
        { id: 'tblB', name: 'Speakers' },
        { id: 'tblC', name: 'Talks' },
      ],
    });
    vi.spyOn(__, 'formatTable').mockImplementation((table) => ({
      ...table,
      name: table.name.toUpperCase(),
    }));
    vi.spyOn(__, 'airtableSeparators').mockReturnValue(separators);
  });

  it('reads the Tables of the Base from the schema endpoint', async () => {
    await tableListRaw({ baseId: 'appDEVREL' });

    expect(__.callApi).toHaveBeenCalledWith('meta/bases/appDEVREL/tables');
  });

  it('prints one line per formatted Table', async () => {
    const actual = await tableListRaw({ baseId: 'appDEVREL', limit: 10 });

    expect(actual).toEqual('tblA▮MEETUPS\ntblB▮SPEAKERS\ntblC▮TALKS');
  });

  it.each([
    { title: '25 by default', options: {}, expected: 25 },
    { title: 'the limit that is passed', options: { limit: 2 }, expected: 2 },
  ])('returns at most $title', async ({ options, expected }) => {
    __.callApi.mockReturnValue({
      tables: _.times(30, (index) => ({ id: `tbl${index}`, name: 'Table' })),
    });
    const actual = await tableListRaw({ baseId: 'appDEVREL', ...options });

    expect(actual.split('\n')).toHaveLength(expected);
  });

  it('prints an empty line for a Base without Tables', async () => {
    __.callApi.mockReturnValue({ tables: [] });

    const actual = await tableListRaw({ baseId: 'appDEVREL' });

    expect(actual).toEqual('');
  });

  it('throws when the Base ID is missing', async () => {
    let actual = null;
    try {
      await tableListRaw({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'AIRTABLE_BASE_ID_MISSING');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('surfaces the failure of the API', async () => {
    __.callApi.mockImplementation(() => {
      throw firostError('AIRTABLE_REQUEST_FAILED', 'Base not found');
    });

    let actual = null;
    try {
      await tableListRaw({ baseId: 'appMISSING' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'AIRTABLE_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', 'Base not found');
  });

  describe('toLine', () => {
    it.each([
      {
        title: 'joins the id and the name',
        input: { id: 'tblA', name: 'Meetups' },
        expected: 'tblA▮Meetups',
      },
      {
        title: 'replaces newlines with a space and removes separators',
        input: { id: 'tblA', name: 'Line one\nLine▮two▯three' },
        expected: 'tblA▮Line one Linetwothree',
      },
    ])('$title', ({ input, expected }) => {
      const actual = __.toLine(input, separators);

      expect(actual).toEqual(expected);
    });
  });
});
