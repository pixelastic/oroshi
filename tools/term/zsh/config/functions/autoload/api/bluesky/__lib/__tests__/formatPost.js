import { formatPost } from '../formatPost.js';

describe('formatPost', () => {
  it('returns the AT URI and the web URL of a record', () => {
    const actual = formatPost({
      uri: 'at://did:plc:abc/app.bsky.feed.post/3kxyz',
      cid: 'bafy',
    });

    expect(actual).toEqual({
      uri: 'at://did:plc:abc/app.bsky.feed.post/3kxyz',
      url: 'https://bsky.app/profile/did:plc:abc/post/3kxyz',
    });
  });
});
