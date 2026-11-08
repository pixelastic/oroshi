import { previewPosts } from '../previewPosts.js';

describe('previewPosts', () => {
  it('describes each post with its length, links, hashtags and mentions', () => {
    const text = 'Café #vitest @pixelastic.bsky.social docs';
    const posts = [
      {
        text,
        line: 2,
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

    const actual = previewPosts(posts);

    expect(actual).toEqual([
      {
        line: 2,
        text,
        graphemes: 41,
        bytes: 42,
        links: ['https://a.io'],
        hashtags: ['vitest'],
        mentions: ['did:plc:pixelastic'],
      },
    ]);
  });
});
