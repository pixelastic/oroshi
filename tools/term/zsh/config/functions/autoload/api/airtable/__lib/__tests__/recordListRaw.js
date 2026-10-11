import { __, airtableRecordListRaw } from '../recordListRaw.js';
import { __ as separatorsMock } from '../separators.js';

describe('airtableRecordListRaw', () => {
  beforeEach(() => {
    vi.spyOn(separatorsMock, 'readIcons').mockReturnValue({
      'table-separator': '▮',
      'table-separator-secondary': '▯',
    });
    vi.spyOn(__, 'callApi').mockReturnValue({
      records: [
        {
          id: 'recA',
          fields: { name: 'Paris', city: 'Paris', tags: ['a', 'b'] },
        },
        { id: 'recB', fields: { name: 'Lyon' } },
      ],
    });
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
      base: 'appDEVREL123',
      table: 'Meetups',
      fields,
    });
    expect(actual).toEqual(expected);
  });

  it('removes newlines and separators from the values', async () => {
    __.callApi.mockReturnValue({
      records: [{ id: 'recA', fields: { name: 'Line one\nLine▮two▯three' } }],
    });
    const actual = await airtableRecordListRaw({
      base: 'appDEVREL123',
      table: 'Meetups',
      fields: ['name'],
    });
    expect(actual).toEqual(['recA▮Line one Linetwothree']);
  });

  it('prints nothing for a Table without Records', async () => {
    __.callApi.mockReturnValue({ records: [] });
    const actual = await airtableRecordListRaw({
      base: 'appDEVREL123',
      table: 'Meetups',
    });
    expect(actual).toEqual([]);
  });

  it('makes exactly one API call, even when Airtable offers a next page', async () => {
    __.callApi.mockReturnValue({
      records: [{ id: 'recA', fields: {} }],
      offset: 'itrNEXT',
    });
    await airtableRecordListRaw({ base: 'appDEVREL123', table: 'Meetups' });
    expect(__.callApi).toHaveBeenCalledTimes(1);
  });

  it.each([
    {
      title: 'requests nothing special by default',
      options: {},
      expected: { pageSize: undefined, sort: undefined, fields: [] },
    },
    {
      title: 'restricts the request to the requested Fields',
      options: { fields: ['name', 'city'] },
      expected: {
        pageSize: undefined,
        sort: undefined,
        fields: ['name', 'city'],
      },
    },
    {
      title: 'limits the page size to the limit',
      options: { limit: 5 },
      expected: { pageSize: 5, sort: undefined, fields: [] },
    },
    {
      title: 'caps the page size at the maximum Airtable allows',
      options: { limit: 500 },
      expected: { pageSize: 100, sort: undefined, fields: [] },
    },
    {
      title: 'sorts ascending on a Field',
      options: { sort: 'date' },
      expected: {
        pageSize: undefined,
        sort: [{ field: 'date', direction: 'asc' }],
        fields: [],
      },
    },
    {
      title: 'sorts descending on a Field prefixed with a dash',
      options: { sort: '-date' },
      expected: {
        pageSize: undefined,
        sort: [{ field: 'date', direction: 'desc' }],
        fields: [],
      },
    },
    {
      title: 'combines page size, sort and Fields',
      options: { limit: 5, sort: '-date', fields: ['name'] },
      expected: {
        pageSize: 5,
        sort: [{ field: 'date', direction: 'desc' }],
        fields: ['name'],
      },
    },
  ])('$title', async ({ options, expected }) => {
    await airtableRecordListRaw({
      base: 'appDEVREL123',
      table: 'Meetups',
      ...options,
    });
    expect(__.callApi).toHaveBeenCalledWith('appDEVREL123/Meetups', {
      query: expected,
    });
  });
});
