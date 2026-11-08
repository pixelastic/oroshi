import { __, callApi } from '../callApi.js';

describe('callApi', () => {
  const response = (status, text) => ({
    ok: status >= 200 && status < 300,
    status,
    text: () => text,
  });
  const sessions = { 'did:plc:abc': { tokenSet: 'stored' } };

  let session;
  let client;
  beforeEach(() => {
    session = {
      fetchHandler: vi
        .fn()
        .mockReturnValue(response(200, JSON.stringify({ records: [] }))),
    };
    client = { restore: vi.fn().mockReturnValue(session) };
    vi.spyOn(__, 'getConfig').mockReturnValue({ tokens: { sessions } });
    vi.spyOn(__, 'createOAuthClient').mockReturnValue(client);
  });

  it('returns the parsed JSON body of the restored session', async () => {
    const actual = await callApi('com.atproto.repo.listRecords', {
      query: { repo: 'did:plc:abc' },
      headers: { Accept: 'application/json' },
    });

    expect(actual).toEqual({ records: [] });
    expect(client.restore).toHaveBeenCalledWith('did:plc:abc');
    expect(session.fetchHandler).toHaveBeenCalledWith(
      '/xrpc/com.atproto.repo.listRecords?repo=did%3Aplc%3Aabc',
      {
        method: 'GET',
        headers: { Accept: 'application/json' },
        body: undefined,
      },
    );
  });

  it('sends a plain object body as JSON', async () => {
    await callApi('com.atproto.repo.createRecord', {
      method: 'POST',
      body: { text: 'hello' },
    });

    const [, request] = session.fetchHandler.mock.calls[0];
    expect(request).toHaveProperty('method', 'POST');
    expect(request).toHaveProperty('body', JSON.stringify({ text: 'hello' }));
    expect(request).toHaveProperty('headers.Content-Type', 'application/json');
  });

  it('returns an empty body as it is', async () => {
    session.fetchHandler.mockReturnValue(response(200, ''));

    const actual = await callApi('com.atproto.repo.deleteRecord');

    expect(actual).toEqual('');
  });

  it.each([
    {
      title: 'the session is missing',
      setup: () => __.getConfig.mockReturnValue({ tokens: { sessions: {} } }),
    },
    {
      title: 'the library cannot refresh the session',
      setup: () =>
        client.restore.mockImplementation(() => {
          throw new Error('The session was revoked');
        }),
    },
    {
      title: 'the PDS answers 401',
      setup: () => session.fetchHandler.mockReturnValue(response(401, '{}')),
    },
  ])('throws the login-required error when $title', async ({ setup }) => {
    setup();

    let actual = null;
    try {
      await callApi('com.atproto.repo.listRecords');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_LOGIN_REQUIRED');
    expect(actual).toHaveProperty('message', 'run bluesky-login');
  });

  it('throws the request error on another failed response', async () => {
    session.fetchHandler.mockReturnValue(response(400, 'InvalidRequest'));

    let actual = null;
    try {
      await callApi('com.atproto.repo.listRecords');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', '400 InvalidRequest');
  });
});
