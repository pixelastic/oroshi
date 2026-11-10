import { firostError } from 'firost';
import { __, resolvePostRef } from '../resolvePostRef.js';

describe('resolvePostRef', () => {
  const uri = 'at://did:plc:abc/app.bsky.feed.post/3k44';
  const rootUri = 'at://did:plc:root/app.bsky.feed.post/3k00';

  const thread = (record) => {
    return {
      thread: {
        $type: 'app.bsky.feed.defs#threadViewPost',
        post: {
          uri,
          cid: 'bafyTarget',
          author: { handle: 'a.bsky.social' },
          record: { createdAt: '2026-03-12T10:00:00.000Z', ...record },
        },
      },
    };
  };

  beforeEach(() => {
    vi.spyOn(__, 'resolveHandle').mockReturnValue('did:plc:abc');
    vi.spyOn(__, 'callPublicApi').mockReturnValue(thread({ text: 'Hello' }));
  });

  it.each([
    { title: 'an AT URI', ref: uri },
    {
      title: 'a bsky.app URL with a DID',
      ref: 'https://bsky.app/profile/did:plc:abc/post/3k44',
    },
  ])('resolves $title to its URI and CID', async ({ ref }) => {
    const actual = await resolvePostRef(ref);

    expect(__.resolveHandle).not.toHaveBeenCalled();
    expect(__.callPublicApi).toHaveBeenCalledWith(
      'app.bsky.feed.getPostThread',
      {
        query: { uri, depth: 0, parentHeight: 0 },
      },
    );
    expect(actual).toEqual({
      uri,
      cid: 'bafyTarget',
      text: 'Hello',
      handle: 'a.bsky.social',
      createdAt: '2026-03-12T10:00:00.000Z',
      root: { uri, cid: 'bafyTarget' },
    });
  });

  it.each([
    {
      title: 'a bsky.app URL',
      ref: 'https://bsky.app/profile/a.bsky.social/post/3k44',
    },
    { title: 'an AT URI', ref: 'at://a.bsky.social/app.bsky.feed.post/3k44' },
  ])('resolves the handle of $title first', async ({ ref }) => {
    await resolvePostRef(ref);

    expect(__.resolveHandle).toHaveBeenCalledWith('a.bsky.social');
    expect(__.callPublicApi).toHaveBeenCalledWith(
      'app.bsky.feed.getPostThread',
      {
        query: { uri, depth: 0, parentHeight: 0 },
      },
    );
  });

  it('names the argument in the error, to match the command', async () => {
    let actual = null;
    try {
      await resolvePostRef('not a post', { argument: 'post' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty(
      'message',
      'Invalid post not a post: pass an AT URI or a bsky.app post URL',
    );
  });

  it('uses the root of the target when the target is a reply', async () => {
    __.callPublicApi.mockReturnValue(
      thread({
        text: 'Hello',
        reply: {
          root: { uri: rootUri, cid: 'bafyRoot' },
          parent: { uri: 'at://did:plc:x/app.bsky.feed.post/3k11', cid: 'p' },
        },
      }),
    );

    const actual = await resolvePostRef(uri);

    expect(actual).toHaveProperty('root', { uri: rootUri, cid: 'bafyRoot' });
  });

  it('uses the target as root when the target is a top-level post', async () => {
    const actual = await resolvePostRef(uri);

    expect(actual).toHaveProperty('root', { uri, cid: 'bafyTarget' });
  });

  it.each([
    { title: 'free text', ref: 'not a post' },
    { title: 'an empty string', ref: '' },
    { title: 'a profile URL', ref: 'https://bsky.app/profile/a.bsky.social' },
    { title: 'a foreign URL', ref: 'https://a.io/profile/a/post/3k44' },
    {
      title: 'an AT URI of a like',
      ref: 'at://did:plc:abc/app.bsky.feed.like/1',
    },
  ])('fails before any call with $title', async ({ ref }) => {
    let actual = null;
    try {
      await resolvePostRef(ref);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_INVALID_ARGUMENT');
    expect(actual).toHaveProperty(
      'message',
      `Invalid --reply-to ${ref}: pass an AT URI or a bsky.app post URL`,
    );
    expect(__.resolveHandle).not.toHaveBeenCalled();
    expect(__.callPublicApi).not.toHaveBeenCalled();
  });

  it('fails when the handle does not resolve', async () => {
    __.resolveHandle.mockReturnValue(null);

    let actual = null;
    try {
      await resolvePostRef('https://bsky.app/profile/gone.bsky.social/post/1');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_INVALID_ARGUMENT');
    expect(actual).toHaveProperty(
      'message',
      'Invalid --reply-to https://bsky.app/profile/gone.bsky.social/post/1: cannot resolve the handle gone.bsky.social',
    );
    expect(__.callPublicApi).not.toHaveBeenCalled();
  });

  it('fails when the post does not exist', async () => {
    __.callPublicApi.mockImplementation(() => {
      throw firostError(
        'BLUESKY_REQUEST_FAILED',
        '400 {"error":"NotFound","message":"Post not found"}',
      );
    });

    let actual = null;
    try {
      await resolvePostRef(uri);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_INVALID_ARGUMENT');
    expect(actual).toHaveProperty(
      'message',
      `Invalid --reply-to ${uri}: cannot find the post ${uri}`,
    );
  });

  it('fails when the thread holds no post', async () => {
    __.callPublicApi.mockReturnValue({
      thread: { $type: 'app.bsky.feed.defs#notFoundPost', uri, notFound: true },
    });

    let actual = null;
    try {
      await resolvePostRef(uri);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_INVALID_ARGUMENT');
  });

  it('lets the other API errors through', async () => {
    __.callPublicApi.mockImplementation(() => {
      throw firostError('BLUESKY_LOGIN_REQUIRED', 'Log in');
    });

    let actual = null;
    try {
      await resolvePostRef(uri);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_LOGIN_REQUIRED');
  });
});
