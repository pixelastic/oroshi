import { formatPost } from '../formatPost.js';

describe('formatPost', () => {
  it.each([
    {
      title: 'a record just created',
      input: {
        uri: 'at://did:plc:abc/app.bsky.feed.post/3kxyz',
        cid: 'bafy',
      },
      expected: {
        uri: 'at://did:plc:abc/app.bsky.feed.post/3kxyz',
        url: 'https://bsky.app/profile/did:plc:abc/post/3kxyz',
      },
    },
    {
      title: 'a post with a handle, a date and a text',
      input: {
        uri: 'at://did:plc:abc/app.bsky.feed.post/3kxyz',
        cid: 'bafy',
        handle: 'a.bsky.social',
        createdAt: '2026-03-12T10:00:00.000Z',
        text: 'Hello',
      },
      expected: {
        uri: 'at://did:plc:abc/app.bsky.feed.post/3kxyz',
        url: 'https://bsky.app/profile/did:plc:abc/post/3kxyz',
        handle: 'a.bsky.social',
        createdAt: '2026-03-12T10:00:00.000Z',
        text: 'Hello',
      },
    },
  ])('returns the AT URI and web URL of $title', ({ input, expected }) => {
    const actual = formatPost(input);

    expect(actual).toEqual(expected);
  });
});
