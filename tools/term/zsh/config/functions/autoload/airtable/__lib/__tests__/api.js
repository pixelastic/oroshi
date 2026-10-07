import { __, airtableApi } from '../api.js';

describe('airtableApi', () => {
  const response = (status, body) => ({
    ok: status >= 200 && status < 300,
    status,
    json: () => body,
  });

  beforeEach(() => {
    vi.stubEnv('AIRTABLE_TOKEN_READ', 'read-token-abc');
    vi.stubEnv('AIRTABLE_TOKEN_WRITE', 'write-token-xyz');
    vi.spyOn(__, 'fetch').mockReturnValue(response(200, { ok: true }));
  });
  afterEach(() => {
    vi.unstubAllEnvs();
  });

  describe('tokens', () => {
    it.each([
      { mode: 'read', expected: 'Bearer read-token-abc' },
      { mode: 'write', expected: 'Bearer write-token-xyz' },
    ])('sends the $mode token in $mode mode', async ({ mode, expected }) => {
      await airtableApi({
        mode,
        method: 'GET',
        base: 'appDEVREL123',
        path: 'Meetups',
      });

      const actual = __.fetch.mock.calls[0][1].headers.Authorization;
      expect(actual).toEqual(expected);
    });

    it('names the missing variable when the token is not set', async () => {
      vi.stubEnv('AIRTABLE_TOKEN_WRITE', '');

      let actual = null;
      try {
        await airtableApi({
          mode: 'write',
          method: 'POST',
          base: 'appDEVREL123',
          path: 'Meetups',
        });
      } catch (error) {
        actual = error;
      }
      expect(actual).toHaveProperty(
        'message',
        'AIRTABLE_TOKEN_WRITE is not set',
      );
    });

    it('rejects an unknown mode', async () => {
      let actual = null;
      try {
        await airtableApi({
          mode: 'delete',
          method: 'GET',
          base: 'appDEVREL123',
          path: 'Meetups',
        });
      } catch (error) {
        actual = error;
      }
      expect(actual).toHaveProperty(
        'message',
        "mode must be read or write, got 'delete'",
      );
    });
  });

  describe('path', () => {
    it.each([
      {
        title: 'encodes a name with spaces and symbols',
        path: 'My Meetups/2026',
        expected:
          'https://api.airtable.com/v0/appDEVREL123/My%20Meetups%2F2026',
      },
      {
        title: 'joins several segments with a slash',
        path: ['My Meetups', 'recA'],
        expected: 'https://api.airtable.com/v0/appDEVREL123/My%20Meetups/recA',
      },
    ])('$title', async ({ path, expected }) => {
      await airtableApi({
        mode: 'read',
        method: 'GET',
        base: 'appDEVREL123',
        path,
      });

      const actual = __.fetch.mock.calls[0][0];
      expect(actual).toEqual(expected);
    });
  });

  describe('host', () => {
    it.each([
      {
        title: 'the API host by default',
        host: undefined,
        expected: 'https://api.airtable.com/v0/appDEVREL123/Meetups',
      },
      {
        title: 'the content host for uploads',
        host: 'content',
        expected: 'https://content.airtable.com/v0/appDEVREL123/Meetups',
      },
    ])('calls $title', async ({ host, expected }) => {
      await airtableApi({
        mode: 'read',
        method: 'GET',
        base: 'appDEVREL123',
        path: 'Meetups',
        host,
      });

      const actual = __.fetch.mock.calls[0][0];
      expect(actual).toEqual(expected);
    });
  });

  describe('schema host', () => {
    it.each([
      {
        title: 'lists the Bases without a Base',
        options: {},
        expected: 'https://api.airtable.com/v0/meta/bases',
      },
      {
        title: 'lists the Tables of a Base',
        options: { base: 'appDEVREL123', path: 'tables' },
        expected: 'https://api.airtable.com/v0/meta/bases/appDEVREL123/tables',
      },
    ])('$title', async ({ options, expected }) => {
      await airtableApi({
        mode: 'read',
        method: 'GET',
        host: 'schema',
        ...options,
      });

      const actual = __.fetch.mock.calls[0][0];
      expect(actual).toEqual(expected);
    });
  });

  describe('query', () => {
    it.each([
      {
        title: 'adds no query string without a query',
        query: undefined,
        expected: 'https://api.airtable.com/v0/appDEVREL123/Meetups',
      },
      {
        title: 'adds no query string for an empty query',
        query: {},
        expected: 'https://api.airtable.com/v0/appDEVREL123/Meetups',
      },
      {
        title: 'sends scalar values',
        query: { pageSize: 5, view: 'Grid' },
        expected:
          'https://api.airtable.com/v0/appDEVREL123/Meetups?pageSize=5&view=Grid',
      },
      {
        title: 'encodes values',
        query: { filterByFormula: "RECORD_ID()='recA'" },
        expected:
          "https://api.airtable.com/v0/appDEVREL123/Meetups?filterByFormula=RECORD_ID()%3D'recA'",
      },
      {
        title: 'sends a list of values as repeated key[]',
        query: { fields: ['name', 'start date'] },
        expected:
          'https://api.airtable.com/v0/appDEVREL123/Meetups?fields[]=name&fields[]=start%20date',
      },
      {
        title: 'sends a list of objects as indexed key[i][property]',
        query: { sort: [{ field: 'date', direction: 'desc' }] },
        expected:
          'https://api.airtable.com/v0/appDEVREL123/Meetups?sort[0][field]=date&sort[0][direction]=desc',
      },
      {
        title: 'skips empty values',
        query: { pageSize: undefined, fields: [], view: null, offset: 'itr1' },
        expected:
          'https://api.airtable.com/v0/appDEVREL123/Meetups?offset=itr1',
      },
    ])('$title', async ({ query, expected }) => {
      await airtableApi({
        mode: 'read',
        method: 'GET',
        base: 'appDEVREL123',
        path: 'Meetups',
        query,
      });

      const actual = __.fetch.mock.calls[0][0];
      expect(actual).toEqual(expected);
    });
  });

  describe('request', () => {
    it('sends the method', async () => {
      await airtableApi({
        mode: 'write',
        method: 'PATCH',
        base: 'appDEVREL123',
        path: 'Meetups/recABC',
      });

      const actual = __.fetch.mock.calls[0][1].method;
      expect(actual).toEqual('PATCH');
    });

    it('sends the body as JSON', async () => {
      const body = { fields: { name: 'Paris' } };
      await airtableApi({
        mode: 'write',
        method: 'POST',
        base: 'appDEVREL123',
        path: 'Meetups',
        body,
      });

      const { body: actualBody, headers } = __.fetch.mock.calls[0][1];
      expect(actualBody).toEqual('{"fields":{"name":"Paris"}}');
      expect(headers).toHaveProperty('Content-Type', 'application/json');
    });

    it('sends no body by default', async () => {
      await airtableApi({
        mode: 'read',
        method: 'GET',
        base: 'appDEVREL123',
        path: 'Meetups',
      });

      const actual = __.fetch.mock.calls[0][1];
      expect(actual).not.toHaveProperty('body');
    });
  });

  describe('response', () => {
    it('returns the parsed body on success', async () => {
      __.fetch.mockReturnValue(response(200, { id: 'recABC' }));

      const actual = await airtableApi({
        mode: 'read',
        method: 'GET',
        base: 'appDEVREL123',
        path: 'Meetups/recABC',
      });
      expect(actual).toEqual({ id: 'recABC' });
    });

    it.each([
      {
        title: 'a message',
        body: {
          error: { type: 'INVALID_PERMISSIONS', message: 'Not permitted' },
        },
        expected: 'Not permitted',
      },
      {
        title: 'only a type',
        body: { error: { type: 'NOT_FOUND' } },
        expected: 'NOT_FOUND',
      },
      {
        title: 'a bare string',
        body: { error: 'NOT_FOUND' },
        expected: 'NOT_FOUND',
      },
      {
        title: 'no error key',
        body: {},
        expected: 'HTTP 500',
      },
      {
        title: 'a body that is not JSON',
        body: null,
        expected: 'HTTP 500',
      },
    ])("throws Airtable's error with $title", async ({ body, expected }) => {
      __.fetch.mockReturnValue(response(500, body));
      if (body === null) {
        __.fetch.mockReturnValue({
          ok: false,
          status: 500,
          json: () => {
            throw new SyntaxError('Unexpected token <');
          },
        });
      }

      let actual = null;
      try {
        await airtableApi({
          mode: 'read',
          method: 'GET',
          base: 'appDEVREL123',
          path: 'Meetups',
        });
      } catch (error) {
        actual = error;
      }
      expect(actual).toHaveProperty('message', expected);
    });

    it('never leaks the token in the error', async () => {
      __.fetch.mockReturnValue(response(500, { error: { message: 'Boom' } }));

      let actual = null;
      try {
        await airtableApi({
          mode: 'read',
          method: 'GET',
          base: 'appDEVREL123',
          path: 'Meetups',
        });
      } catch (error) {
        actual = error;
      }
      expect(JSON.stringify(actual)).not.toContain('read-token-abc');
      expect(actual.message).not.toContain('read-token-abc');
    });
  });
});
