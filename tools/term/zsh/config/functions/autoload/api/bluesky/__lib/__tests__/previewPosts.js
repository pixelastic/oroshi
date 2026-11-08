import { __, previewPosts } from '../previewPosts.js';

describe('previewPosts', () => {
  beforeEach(() => {
    vi.spyOn(__, 'fileSize').mockReturnValue(52_000);
  });

  it('describes each post with its length, links, hashtags, mentions and images', async () => {
    const text = 'Café #vitest @pixelastic.bsky.social docs';
    const posts = [
      {
        text,
        line: 2,
        images: [{ alt: 'A cat', path: '/drafts/cat.png', line: 4 }],
        facets: [
          {
            index: { byteStart: 0, byteEnd: 5 },
            features: [
              { $type: 'app.bsky.richtext.facet#link', uri: 'https://a.io' },
            ],
          },
          {
            index: { byteStart: 6, byteEnd: 13 },
            features: [{ $type: 'app.bsky.richtext.facet#tag', tag: 'vitest' }],
          },
          {
            index: { byteStart: 14, byteEnd: 37 },
            features: [
              {
                $type: 'app.bsky.richtext.facet#mention',
                did: 'did:plc:pixelastic',
              },
            ],
          },
        ],
      },
    ];

    const actual = await previewPosts(posts);

    expect(actual).toEqual([
      {
        line: 2,
        text,
        graphemes: 41,
        bytes: 42,
        links: ['https://a.io'],
        hashtags: ['vitest'],
        mentions: ['did:plc:pixelastic'],
        images: [{ alt: 'A cat', path: '/drafts/cat.png', size: 52_000 }],
        card: null,
        warnings: [],
        replyTo: null,
      },
    ]);
  });

  it('shows the post a reply goes to', async () => {
    const posts = [
      {
        text: 'Agreed',
        line: 1,
        images: [],
        facets: [],
        replyTo: {
          uri: 'at://did:plc:abc/app.bsky.feed.post/3k44',
          cid: 'bafy',
          text: 'Original',
          root: { uri: 'at://did:plc:abc/app.bsky.feed.post/3k00', cid: 'r' },
        },
      },
    ];

    const actual = await previewPosts(posts);

    expect(actual[0]).toHaveProperty('replyTo', {
      uri: 'at://did:plc:abc/app.bsky.feed.post/3k44',
      text: 'Original',
    });
  });

  it('shows the card and the warnings of a post', async () => {
    const posts = [
      {
        text: 'See https://a.io',
        line: 1,
        images: [],
        facets: [],
        card: {
          uri: 'https://a.io',
          title: 'A',
          description: 'About A',
          imageUrl: 'https://a.io/cover.png',
        },
        warnings: ['1 Something'],
      },
    ];

    const actual = await previewPosts(posts);

    expect(actual[0]).toMatchObject({
      card: {
        title: 'A',
        description: 'About A',
        imageUrl: 'https://a.io/cover.png',
      },
      warnings: ['1 Something'],
    });
  });
});
