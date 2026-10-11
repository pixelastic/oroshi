import { __ as separatorsMock } from '../separators.js';
import { __, airtableTableListRaw } from '../tableListRaw.js';

describe('airtableTableListRaw', () => {
  beforeEach(() => {
    vi.spyOn(separatorsMock, 'readIcons').mockReturnValue({
      'table-separator': '▮',
      'table-separator-secondary': '▯',
    });
    vi.spyOn(__, 'callApi').mockReturnValue({
      tables: [
        { id: 'tblA', name: 'Meetups', fields: [], views: [] },
        { id: 'tblB', name: 'Speakers', fields: [], views: [] },
      ],
    });
  });

  it('prints the ID and the name of each Table', async () => {
    const actual = await airtableTableListRaw({ base: 'appDEVREL123' });
    expect(actual).toEqual(['tblA▮Meetups', 'tblB▮Speakers']);
  });

  it.each([
    {
      title: 'removes newlines and separators from the names',
      tables: [{ id: 'tblA', name: 'Line one\nLine▮two' }],
      expected: ['tblA▮Line one Linetwo'],
    },
    {
      title: 'prints nothing for a Base without Tables',
      tables: [],
      expected: [],
    },
  ])('$title', async ({ tables, expected }) => {
    __.callApi.mockReturnValue({ tables });
    const actual = await airtableTableListRaw({ base: 'appDEVREL123' });
    expect(actual).toEqual(expected);
  });

  it('reads the schema of the Base', async () => {
    await airtableTableListRaw({ base: 'appDEVREL123' });
    expect(__.callApi).toHaveBeenCalledWith('meta/bases/appDEVREL123/tables');
  });
});
