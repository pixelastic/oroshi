import { __, airtableApi } from '../api.js';

describe('airtableApi', () => {
  const response = (status, body) => ({
    ok: status >= 200 && status < 300,
    status,
    json: () => body,
  });

  beforeEach(() => {
    vi.stubEnv('AIRTABLE_BASE_DEVREL', 'appDEVREL123');
    vi.stubEnv('AIRTABLE_TOKEN_READ', 'read-token-abc');
    vi.stubEnv('AIRTABLE_TOKEN_WRITE', 'write-token-xyz');
    vi.spyOn(__, 'fetch').mockReturnValue(response(200, { ok: true }));
  });
  afterEach(() => {
    vi.unstubAllEnvs();
  });

  describe('Base alias', () => {
    it.each([
      { title: 'alias', input: 'DevRel', expected: 'appDEVREL123' },
      { title: 'lowercase alias', input: 'devrel', expected: 'appDEVREL123' },
      { title: 'Base ID', input: 'appXXX999', expected: 'appXXX999' },
    ])('resolves a $title', async ({ input, expected }) => {
      await airtableApi({
        mode: 'read',
        method: 'GET',
        base: input,
        path: 'Meetups',
      });

      const actual = __.fetch.mock.calls[0][0];
      expect(actual).toEqual(`https://api.airtable.com/v0/${expected}/Meetups`);
    });

    it('names the missing variable when the alias is unknown', async () => {
      let actual = null;
      try {
        await airtableApi({
          mode: 'read',
          method: 'GET',
          base: 'Nowhere',
          path: 'Meetups',
        });
      } catch (error) {
        actual = error;
      }
      expect(actual).toHaveProperty(
        'message',
        'AIRTABLE_BASE_NOWHERE is not set',
      );
    });
  });

  describe('tokens', () => {
    it.each([
      { mode: 'read', expected: 'Bearer read-token-abc' },
      { mode: 'write', expected: 'Bearer write-token-xyz' },
    ])('sends the $mode token in $mode mode', async ({ mode, expected }) => {
      await airtableApi({
        mode,
        method: 'GET',
        base: 'DevRel',
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
          base: 'DevRel',
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
          base: 'DevRel',
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

  describe('request', () => {
    it('sends the method', async () => {
      await airtableApi({
        mode: 'write',
        method: 'PATCH',
        base: 'DevRel',
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
        base: 'DevRel',
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
        base: 'DevRel',
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
        base: 'DevRel',
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
          base: 'DevRel',
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
          base: 'DevRel',
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
