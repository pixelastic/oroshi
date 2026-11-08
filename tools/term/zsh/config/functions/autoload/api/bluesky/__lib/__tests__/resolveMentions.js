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
    vi.spyOn(__, 'resolveHandle').mockImplementation((handle) => {
      return handle === 'unknown.bsky.social' ? null : `did:plc:${handle}`;
    });
  });

  it('replaces the handle of a mention with its DID', async () => {
    const posts = [
      { text: '@a.bsky.social', line: 1, facets: [mention('a.bsky.social')] },
    ];

    const actual = await resolveMentions(posts);

    expect(__.resolveHandle).toHaveBeenCalledWith('a.bsky.social');
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

    expect(__.resolveHandle).toHaveBeenCalledTimes(1);
  });

  it('leaves the other facets untouched and makes no call without mention', async () => {
    const posts = [{ text: '', line: 1, facets: [tag] }];

    const actual = await resolveMentions(posts);

    expect(actual).toEqual(posts);
    expect(__.resolveHandle).not.toHaveBeenCalled();
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
});
