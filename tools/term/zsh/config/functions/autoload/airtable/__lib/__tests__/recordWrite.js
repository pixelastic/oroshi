import { __ as apiMock } from '../api.js';
import { airtableRecordWrite } from '../recordWrite.js';

describe('airtableRecordWrite', () => {
  beforeEach(() => {
    vi.stubEnv('AIRTABLE_BASE_DEVREL', 'appDEVREL123');
    vi.stubEnv('AIRTABLE_TOKEN_WRITE', 'write-token-abc');
    vi.stubEnv('AIRTABLE_TOKEN_READ', 'read-token-abc');
    vi.spyOn(apiMock, 'fetch').mockReturnValue({
      ok: true,
      status: 200,
      json: () => ({ id: 'recNEW', fields: {} }),
    });
  });
  afterEach(() => {
    vi.unstubAllEnvs();
  });

  const request = () => apiMock.fetch.mock.calls[0][1];
  const requestedUrl = () => decodeURIComponent(apiMock.fetch.mock.calls[0][0]);
  const sentBody = () => JSON.parse(request().body);

  describe('without a Record ID', () => {
    it('creates a Record and returns its ID', async () => {
      const actual = await airtableRecordWrite({
        base: 'DevRel',
        table: 'Meetups',
        fields: { name: 'Paris Meetup' },
      });
      expect(actual).toEqual('recNEW');
      expect(request().method).toEqual('POST');
      expect(requestedUrl()).toEqual(
        'https://api.airtable.com/v0/appDEVREL123/Meetups',
      );
      expect(sentBody()).toEqual({ fields: { name: 'Paris Meetup' } });
    });

    it('keeps the type of numbers and booleans', async () => {
      await airtableRecordWrite({
        base: 'DevRel',
        table: 'Meetups',
        fields: { attendees: 42, confirmed: true },
      });
      expect(sentBody().fields).toStrictEqual({
        attendees: 42,
        confirmed: true,
      });
    });
  });

  describe('with a Record ID', () => {
    it('updates that Record and returns its ID', async () => {
      apiMock.fetch.mockReturnValue({
        ok: true,
        status: 200,
        json: () => ({ id: 'recABC', fields: {} }),
      });

      const actual = await airtableRecordWrite({
        base: 'DevRel',
        table: 'Meetups',
        record: 'recABC',
        fields: { name: 'Paris Meetup' },
      });
      expect(actual).toEqual('recABC');
      expect(request().method).toEqual('PATCH');
      expect(requestedUrl()).toEqual(
        'https://api.airtable.com/v0/appDEVREL123/Meetups/recABC',
      );
      expect(sentBody()).toEqual({ fields: { name: 'Paris Meetup' } });
    });
  });

  describe('tokens', () => {
    it('sends the Write token', async () => {
      await airtableRecordWrite({
        base: 'DevRel',
        table: 'Meetups',
        fields: { name: 'Paris Meetup' },
      });
      expect(request().headers.Authorization).toEqual('Bearer write-token-abc');
    });

    it('throws and names the variable when the Write token is missing', async () => {
      vi.stubEnv('AIRTABLE_TOKEN_WRITE', '');

      let actual = null;
      try {
        await airtableRecordWrite({
          base: 'DevRel',
          table: 'Meetups',
          fields: { name: 'Paris Meetup' },
        });
      } catch (error) {
        actual = error;
      }
      expect(actual).toHaveProperty(
        'message',
        'AIRTABLE_TOKEN_WRITE is not set',
      );
      expect(apiMock.fetch).not.toHaveBeenCalled();
    });
  });

  describe('Airtable errors', () => {
    it('throws the message of Airtable', async () => {
      apiMock.fetch.mockReturnValue({
        ok: false,
        status: 422,
        json: () => ({
          error: { type: 'UNKNOWN_FIELD_NAME', message: 'Unknown field name' },
        }),
      });

      let actual = null;
      try {
        await airtableRecordWrite({
          base: 'DevRel',
          table: 'Meetups',
          fields: { nope: 1 },
        });
      } catch (error) {
        actual = error;
      }
      expect(actual).toHaveProperty('message', 'Unknown field name');
    });
  });
});
