import { firostError } from 'firost';
import { __, resolveMentions } from '../resolveMentions.js';

describe('resolveMentions', () => {
  const mention = (handle) => {
    return {
      index: { byteStart: 0, byteEnd: 5 },
      features: [{ $type: 'app.bsky.richtext.facet#mention', handle }],
    };
  };
  const tag = {
    index: { byteStart: 6, byteEnd: 9 },
    features: [{ $type: 'app.bsky.richtext.facet#tag', tag: 'a' }],
  };

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockImplementation((path, { query }) => {
      if (query.handle === 'unknown.bsky.social') {
        throw firostError(
          'BLUESKY_REQUEST_FAILED',
          '400 {"error":"InvalidRequest","message":"Unable to resolve handle"}',
        );
      }
      return { did: `did:plc:${query.handle}` };
    });
  });

  it('replaces the handle of a mention with its DID', async () => {
    const posts = [
      { text: '@a.bsky.social', line: 1, facets: [mention('a.bsky.social')] },
    ];

    const actual = await resolveMentions(posts);

    expect(__.callApi).toHaveBeenCalledWith(
      'com.atproto.identity.resolveHandle',
      { query: { handle: 'a.bsky.social' } },
    );
    expect(actual).toEqual([
      {
        text: '@a.bsky.social',
        line: 1,
        facets: [
          {
            index: { byteStart: 0, byteEnd: 5 },
            features: [
              {
                $type: 'app.bsky.richtext.facet#mention',
                did: 'did:plc:a.bsky.social',
              },
            ],
          },
        ],
      },
    ]);
  });

  it('resolves a handle once, even across posts', async () => {
    const posts = [
      {
        text: '',
        line: 1,
        facets: [mention('a.bsky.social'), mention('a.bsky.social')],
      },
      { text: '', line: 5, facets: [mention('a.bsky.social')] },
    ];

    await resolveMentions(posts);

    expect(__.callApi).toHaveBeenCalledTimes(1);
  });

  it('leaves the other facets untouched and makes no call without mention', async () => {
    const posts = [{ text: '', line: 1, facets: [tag] }];

    const actual = await resolveMentions(posts);

    expect(actual).toEqual(posts);
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('fails and names every handle that does not resolve', async () => {
    const posts = [
      {
        text: '',
        line: 1,
        facets: [mention('unknown.bsky.social'), mention('a.bsky.social')],
      },
    ];

    let actual = null;
    try {
      await resolveMentions(posts);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_UNKNOWN_HANDLE');
    expect(actual).toHaveProperty(
      'message',
      'Cannot resolve the handle: @unknown.bsky.social',
    );
  });

  it('lets the other API errors through', async () => {
    __.callApi.mockImplementation(() => {
      throw firostError('BLUESKY_LOGIN_REQUIRED', 'Log in');
    });
    const posts = [{ text: '', line: 1, facets: [mention('a.bsky.social')] }];

    let actual = null;
    try {
      await resolveMentions(posts);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_LOGIN_REQUIRED');
  });
});
