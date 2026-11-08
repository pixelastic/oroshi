import { __, postDelete } from '../postDelete.js';

describe('postDelete', () => {
  const uri = 'at://did:plc:me/app.bsky.feed.post/3k44';
  const target = {
    uri,
    cid: 'bafyTarget',
    text: 'Oops',
    handle: 'me.bsky.social',
    createdAt: '2026-03-12T10:00:00.000Z',
    root: { uri, cid: 'bafyTarget' },
  };

  beforeEach(() => {
    vi.spyOn(__, 'resolvePostRef').mockReturnValue(target);
    vi.spyOn(__, 'getConfig').mockReturnValue({
      tokens: { sessions: { 'did:plc:me': {} } },
    });
    vi.spyOn(__, 'callApi').mockReturnValue('');
  });

  it('deletes my post and returns it', async () => {
    const actual = await postDelete({ ref: uri });

    expect(__.resolvePostRef).toHaveBeenCalledWith(uri, { argument: 'post' });
    expect(__.callApi).toHaveBeenCalledWith('com.atproto.repo.deleteRecord', {
      method: 'POST',
      body: {
        repo: 'did:plc:me',
        collection: 'app.bsky.feed.post',
        rkey: '3k44',
      },
    });
    expect(actual).toEqual({
      uri,
      url: 'https://bsky.app/profile/did:plc:me/post/3k44',
      handle: 'me.bsky.social',
      createdAt: '2026-03-12T10:00:00.000Z',
      text: 'Oops',
    });
  });

  it('fails on the post of someone else, and deletes nothing', async () => {
    __.getConfig.mockReturnValue({
      tokens: { sessions: { 'did:plc:other': {} } },
    });

    let actual = null;
    try {
      await postDelete({ ref: uri });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_NOT_OWN_POST');
    expect(actual).toHaveProperty(
      'message',
      `Cannot delete ${uri}: it belongs to another account`,
    );
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
