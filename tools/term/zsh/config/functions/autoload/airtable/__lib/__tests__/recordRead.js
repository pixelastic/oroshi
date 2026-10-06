import { __ as apiMock } from '../api.js';
import { airtableRecordRead } from '../recordRead.js';

describe('airtableRecordRead', () => {
  const record = {
    id: 'recABC',
    fields: { name: 'Paris Meetup', description: 'Line one\nLine two' },
  };

  beforeEach(() => {
    vi.stubEnv('AIRTABLE_BASE_DEVREL', 'appDEVREL123');
    vi.stubEnv('AIRTABLE_TOKEN_READ', 'read-token-abc');
    vi.spyOn(apiMock, 'fetch').mockReturnValue({
      ok: true,
      status: 200,
      json: () => ({ records: [record] }),
    });
  });
  afterEach(() => {
    vi.unstubAllEnvs();
  });

  const requestedUrl = () => decodeURIComponent(apiMock.fetch.mock.calls[0][0]);

  it('returns the fields of the Record', async () => {
    const actual = await airtableRecordRead({
      base: 'DevRel',
      table: 'Meetups',
      record: 'recABC',
    });
    expect(actual).toEqual(record.fields);
  });

  it('filters on the Record ID', async () => {
    await airtableRecordRead({
      base: 'appXXX',
      table: 'Meetups',
      record: 'recABC',
    });
    expect(requestedUrl()).toContain("filterByFormula=RECORD_ID()='recABC'");
  });

  it('restricts the request to the requested Fields', async () => {
    await airtableRecordRead({
      base: 'DevRel',
      table: 'Meetups',
      record: 'recABC',
      fields: ['name', 'date'],
    });
    expect(requestedUrl()).toContain('fields[]=name&fields[]=date');
  });

  it('requests every Field by default', async () => {
    await airtableRecordRead({
      base: 'DevRel',
      table: 'Meetups',
      record: 'recABC',
    });
    expect(requestedUrl()).not.toContain('fields[]');
  });

  it('throws "Record not found" when no Record matches', async () => {
    apiMock.fetch.mockReturnValue({
      ok: true,
      status: 200,
      json: () => ({ records: [] }),
    });

    let actual = null;
    try {
      await airtableRecordRead({
        base: 'DevRel',
        table: 'Meetups',
        record: 'recNONE',
      });
    } catch (error) {
      actual = error;
    }
    expect(actual).toHaveProperty('message', 'Record not found');
  });
});
