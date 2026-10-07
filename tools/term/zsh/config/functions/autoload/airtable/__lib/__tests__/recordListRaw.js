import { __ as apiMock } from '../api.js';
import { airtableRecordListRaw } from '../recordListRaw.js';
import { __ as separatorsMock } from '../separators.js';

describe('airtableRecordListRaw', () => {
  const respondWith = (response) => {
    apiMock.fetch.mockReturnValue({
      ok: true,
      status: 200,
      json: () => response,
    });
  };
  const requestedUrl = () => decodeURIComponent(apiMock.fetch.mock.calls[0][0]);

  beforeEach(() => {
    vi.stubEnv('AIRTABLE_BASE_DEVREL', 'appDEVREL123');
    vi.stubEnv('AIRTABLE_TOKEN_READ', 'read-token-abc');
    vi.spyOn(separatorsMock, 'readIcons').mockReturnValue({
      'table-separator': '▮',
      'table-separator-secondary': '▯',
    });
    vi.spyOn(apiMock, 'fetch');
    respondWith({
      records: [
        {
          id: 'recA',
          fields: { name: 'Paris', city: 'Paris', tags: ['a', 'b'] },
        },
        { id: 'recB', fields: { name: 'Lyon' } },
      ],
    });
  });
  afterEach(() => {
    vi.unstubAllEnvs();
  });

  it.each([
    {
      title: 'prints only the Record ID without --fields',
      fields: undefined,
      expected: ['recA', 'recB'],
    },
    {
      title: 'prints the ID then the Fields in the order given',
      fields: ['city', 'name'],
      expected: ['recA▮Paris▮Paris', 'recB▮▮Lyon'],
    },
    {
      title: 'leaves an empty column for an empty Field',
      fields: ['name', 'city', 'tags'],
      expected: ['recA▮Paris▮Paris▮a▯b', 'recB▮Lyon▮▮'],
    },
    {
      title:
        'joins the values of a multi-value Field with the lighter separator',
      fields: ['tags'],
      expected: ['recA▮a▯b', 'recB▮'],
    },
  ])('$title', async ({ fields, expected }) => {
    const actual = await airtableRecordListRaw({
      base: 'DevRel',
      table: 'Meetups',
      fields,
    });
    expect(actual).toEqual(expected);
  });

  it('removes newlines and separators from the values', async () => {
    respondWith({
      records: [{ id: 'recA', fields: { name: 'Line one\nLine▮two▯three' } }],
    });
    const actual = await airtableRecordListRaw({
      base: 'DevRel',
      table: 'Meetups',
      fields: ['name'],
    });
    expect(actual).toEqual(['recA▮Line one Linetwothree']);
  });

  it('prints nothing for a Table without Records', async () => {
    respondWith({ records: [] });
    const actual = await airtableRecordListRaw({
      base: 'DevRel',
      table: 'Meetups',
    });
    expect(actual).toEqual([]);
  });

  it('makes exactly one API call, even when Airtable offers a next page', async () => {
    respondWith({ records: [{ id: 'recA', fields: {} }], offset: 'itrNEXT' });
    await airtableRecordListRaw({ base: 'DevRel', table: 'Meetups' });
    expect(apiMock.fetch).toHaveBeenCalledTimes(1);
  });

  it('reads with the Read token', async () => {
    await airtableRecordListRaw({ base: 'DevRel', table: 'Meetups' });
    expect(apiMock.fetch).toHaveBeenCalledWith(
      'https://api.airtable.com/v0/appDEVREL123/Meetups',
      {
        method: 'GET',
        headers: { Authorization: 'Bearer read-token-abc' },
      },
    );
  });

  it.each([
    {
      title: 'restricts the request to the requested Fields',
      options: { fields: ['name', 'city'] },
      expected:
        'https://api.airtable.com/v0/appDEVREL123/Meetups?fields[]=name&fields[]=city',
    },
    {
      title: 'limits the page size to the limit',
      options: { limit: 5 },
      expected: 'https://api.airtable.com/v0/appDEVREL123/Meetups?pageSize=5',
    },
    {
      title: 'caps the page size at the maximum Airtable allows',
      options: { limit: 500 },
      expected: 'https://api.airtable.com/v0/appDEVREL123/Meetups?pageSize=100',
    },
    {
      title: 'sorts ascending on a Field',
      options: { sort: 'date' },
      expected:
        'https://api.airtable.com/v0/appDEVREL123/Meetups?sort[0][field]=date&sort[0][direction]=asc',
    },
    {
      title: 'sorts descending on a Field prefixed with a dash',
      options: { sort: '-date' },
      expected:
        'https://api.airtable.com/v0/appDEVREL123/Meetups?sort[0][field]=date&sort[0][direction]=desc',
    },
    {
      title: 'combines page size, sort and Fields',
      options: { limit: 5, sort: '-date', fields: ['name'] },
      expected:
        'https://api.airtable.com/v0/appDEVREL123/Meetups?pageSize=5&sort[0][field]=date&sort[0][direction]=desc&fields[]=name',
    },
  ])('$title', async ({ options, expected }) => {
    await airtableRecordListRaw({
      base: 'DevRel',
      table: 'Meetups',
      ...options,
    });
    expect(requestedUrl()).toEqual(expected);
  });
});
