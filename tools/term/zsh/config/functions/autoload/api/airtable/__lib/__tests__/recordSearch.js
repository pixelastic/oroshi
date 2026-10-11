import { __, airtableRecordSearch } from '../recordSearch.js';

describe('airtableRecordSearch', () => {
  const records = [
    { id: 'recA', fields: { name: 'Datadog User Group Paris' } },
    { id: 'recB', fields: { name: 'datadog Lyon', date: '2026-12-02' } },
  ];
  const formula = "SEARCH(LOWER('datadog'),LOWER({name}))";

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ records });
  });

  const search = (options) =>
    airtableRecordSearch({
      base: 'appDEVREL123',
      table: 'Meetups',
      field: 'name',
      text: 'datadog',
      ...options,
    });

  it('returns the matching Records with their ID and Fields', async () => {
    const actual = await search();
    expect(actual).toEqual(records);
  });

  it('returns an empty list when nothing matches', async () => {
    __.callApi.mockReturnValue({ records: [] });
    const actual = await search({ text: 'nothing' });
    expect(actual).toEqual([]);
  });

  it.each([
    {
      title: 'requests every Field by default',
      options: {},
      expected: { filterByFormula: formula, pageSize: undefined, fields: [] },
    },
    {
      title: 'matches the Field case-insensitively',
      options: { text: 'DataDog' },
      expected: {
        filterByFormula: "SEARCH(LOWER('DataDog'),LOWER({name}))",
        pageSize: undefined,
        fields: [],
      },
    },
    {
      title: 'escapes quotes and backslashes of the text',
      options: { text: 'it\'s a "test" \\' },
      expected: {
        filterByFormula:
          "SEARCH(LOWER('it\\'s a \"test\" \\\\'),LOWER({name}))",
        pageSize: undefined,
        fields: [],
      },
    },
    {
      title: 'escapes the braces of the Field name',
      options: { field: 'a}b' },
      expected: {
        filterByFormula: "SEARCH(LOWER('datadog'),LOWER({a\\}b}))",
        pageSize: undefined,
        fields: [],
      },
    },
    {
      title: 'restricts the request to the requested Fields',
      options: { fields: ['name', 'date'] },
      expected: {
        filterByFormula: formula,
        pageSize: undefined,
        fields: ['name', 'date'],
      },
    },
    {
      title: 'limits the number of Records',
      options: { limit: 5 },
      expected: { filterByFormula: formula, pageSize: 5, fields: [] },
    },
    {
      title: 'caps the number of Records at 100',
      options: { limit: 500 },
      expected: { filterByFormula: formula, pageSize: 100, fields: [] },
    },
  ])('$title', async ({ options, expected }) => {
    await search(options);
    expect(__.callApi).toHaveBeenCalledWith('appDEVREL123/Meetups', {
      query: expected,
    });
  });
});
