import { __, postRead } from '../postRead.js';

describe('postRead', () => {
  const uri = 'at://did:plc:abc/app.bsky.feed.post/3k44';

  beforeEach(() => {
    vi.spyOn(__, 'resolvePostRef').mockReturnValue({
      uri,
      cid: 'bafyTarget',
      text: 'Hello',
      handle: 'a.bsky.social',
      createdAt: '2026-03-12T10:00:00.000Z',
      root: { uri, cid: 'bafyTarget' },
    });
  });

  it.each([
    { title: 'an AT URI', ref: uri },
    {
      title: 'a bsky.app URL',
      ref: 'https://bsky.app/profile/a.bsky.social/post/3k44',
    },
  ])('returns the post of $title', async ({ ref }) => {
    const actual = await postRead({ ref });

    expect(__.resolvePostRef).toHaveBeenCalledWith(ref, { argument: 'post' });
    expect(actual).toEqual({
      uri,
      url: 'https://bsky.app/profile/did:plc:abc/post/3k44',
      handle: 'a.bsky.social',
      createdAt: '2026-03-12T10:00:00.000Z',
      text: 'Hello',
    });
  });
});
