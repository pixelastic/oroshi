import { __ as apiMock } from '../api.js';
import { __ as separatorsMock } from '../separators.js';
import { airtableTableListRaw } from '../tableListRaw.js';

describe('airtableTableListRaw', () => {
  const respondWith = (response) => {
    apiMock.fetch.mockReturnValue({
      ok: true,
      status: 200,
      json: () => response,
    });
  };

  beforeEach(() => {
    vi.stubEnv('AIRTABLE_TOKEN_READ', 'read-token-abc');
    vi.spyOn(separatorsMock, 'readIcons').mockReturnValue({
      'table-separator': '▮',
      'table-separator-secondary': '▯',
    });
    vi.spyOn(apiMock, 'fetch');
    respondWith({
      tables: [
        { id: 'tblA', name: 'Meetups', fields: [], views: [] },
        { id: 'tblB', name: 'Speakers', fields: [], views: [] },
      ],
    });
  });
  afterEach(() => {
    vi.unstubAllEnvs();
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
    respondWith({ tables });
    const actual = await airtableTableListRaw({ base: 'appDEVREL123' });
    expect(actual).toEqual(expected);
  });

  it('reads the schema of the Base with the Read token', async () => {
    await airtableTableListRaw({ base: 'appDEVREL123' });
    expect(apiMock.fetch).toHaveBeenCalledWith(
      'https://api.airtable.com/v0/meta/bases/appDEVREL123/tables',
      {
        method: 'GET',
        headers: { Authorization: 'Bearer read-token-abc' },
      },
    );
  });
});
