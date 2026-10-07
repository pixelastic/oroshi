import { __ as apiMock } from '../api.js';
import { airtableRecordSearch } from '../recordSearch.js';

describe('airtableRecordSearch', () => {
  const records = [
    { id: 'recA', fields: { name: 'Datadog User Group Paris' } },
    { id: 'recB', fields: { name: 'datadog Lyon', date: '2026-12-02' } },
  ];
  const tableUrl = 'https://api.airtable.com/v0/appDEVREL123/Meetups';
  const formula = "filterByFormula=SEARCH(LOWER('datadog'),LOWER({name}))";

  beforeEach(() => {
    vi.stubEnv('AIRTABLE_TOKEN_READ', 'read-token-abc');
    vi.spyOn(apiMock, 'fetch').mockReturnValue({
      ok: true,
      status: 200,
      json: () => ({ records }),
    });
  });
  afterEach(() => {
    vi.unstubAllEnvs();
  });

  const search = (options) =>
    airtableRecordSearch({
      base: 'appDEVREL123',
      table: 'Meetups',
      field: 'name',
      text: 'datadog',
      ...options,
    });
  const requestedUrl = () => decodeURIComponent(apiMock.fetch.mock.calls[0][0]);

  it('returns the matching Records with their ID and Fields', async () => {
    const expected = [
      { id: 'recA', fields: { name: 'Datadog User Group Paris' } },
      { id: 'recB', fields: { name: 'datadog Lyon', date: '2026-12-02' } },
    ];
    const actual = await search();
    expect(actual).toEqual(expected);
  });

  it('returns an empty list when nothing matches', async () => {
    apiMock.fetch.mockReturnValue({
      ok: true,
      status: 200,
      json: () => ({ records: [] }),
    });
    const expected = [];
    const actual = await search({ text: 'nothing' });
    expect(actual).toEqual(expected);
  });

  it.each([
    {
      title: 'requests every Field by default',
      options: {},
      expected: `${tableUrl}?${formula}`,
    },
    {
      title: 'matches the Field case-insensitively',
      options: { text: 'DataDog' },
      expected: `${tableUrl}?filterByFormula=SEARCH(LOWER('DataDog'),LOWER({name}))`,
    },
    {
      title: 'escapes quotes and backslashes of the text',
      options: { text: 'it\'s a "test" \\' },
      expected: `${tableUrl}?filterByFormula=SEARCH(LOWER('it\\'s a "test" \\\\'),LOWER({name}))`,
    },
    {
      title: 'escapes the braces of the Field name',
      options: { field: 'a}b' },
      expected: `${tableUrl}?filterByFormula=SEARCH(LOWER('datadog'),LOWER({a\\}b}))`,
    },
    {
      title: 'restricts the request to the requested Fields',
      options: { fields: ['name', 'date'] },
      expected: `${tableUrl}?${formula}&fields[]=name&fields[]=date`,
    },
    {
      title: 'limits the number of Records',
      options: { limit: 5 },
      expected: `${tableUrl}?${formula}&pageSize=5`,
    },
    {
      title: 'caps the number of Records at 100',
      options: { limit: 500 },
      expected: `${tableUrl}?${formula}&pageSize=100`,
    },
  ])('$title', async ({ options, expected }) => {
    await search(options);
    const actual = requestedUrl();
    expect(actual).toEqual(expected);
  });

  it('passes the Airtable error through', async () => {
    apiMock.fetch.mockReturnValue({
      ok: false,
      status: 422,
      json: () => ({ error: { message: 'Invalid formula' } }),
    });

    let actual = null;
    try {
      await search();
    } catch (error) {
      actual = error;
    }
    expect(actual).toHaveProperty('message', 'Invalid formula');
  });
});
