import { __, callPublicApi } from '../callPublicApi.js';

describe('callPublicApi', () => {
  const response = (status, text) => ({
    ok: status >= 200 && status < 300,
    status,
    text: () => text,
  });

  beforeEach(() => {
    vi.spyOn(__, 'fetch').mockReturnValue(
      response(200, JSON.stringify({ feed: [] })),
    );
  });

  it('returns the parsed JSON body, without any session', async () => {
    const actual = await callPublicApi('app.bsky.feed.getAuthorFeed', {
      query: { actor: 'a.bsky.social', limit: 5 },
    });

    expect(actual).toEqual({ feed: [] });
    expect(__.fetch).toHaveBeenCalledWith(
      'https://public.api.bsky.app/xrpc/app.bsky.feed.getAuthorFeed?actor=a.bsky.social&limit=5',
    );
  });

  it('fails with the status and the body when the API answers an error', async () => {
    __.fetch.mockReturnValue(response(400, '{"error":"InvalidRequest"}'));

    let actual = null;
    try {
      await callPublicApi('app.bsky.feed.getPostThread');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', '400 {"error":"InvalidRequest"}');
  });

  it('fails when the network is down', async () => {
    __.fetch.mockImplementation(() => {
      throw new Error('fetch failed');
    });

    let actual = null;
    try {
      await callPublicApi('app.bsky.feed.getPostThread');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_REQUEST_FAILED');
  });
});
