import { __, postListRaw } from '../postListRaw.js';

describe('postListRaw', () => {
  const record = (rkey, createdAt, text) => {
    return {
      uri: `at://did:plc:me/app.bsky.feed.post/${rkey}`,
      cid: `bafy${rkey}`,
      value: { $type: 'app.bsky.feed.post', text, createdAt },
    };
  };

  beforeEach(() => {
    vi.spyOn(__, 'getConfig').mockReturnValue({
      tokens: { sessions: { 'did:plc:me': {} } },
    });
    vi.spyOn(__, 'callPublicApi').mockReturnValue({ feed: [] });
    vi.spyOn(__, 'callApi').mockReturnValue({
      records: [
        record('3k11', '2026-03-10T10:00:00.000Z', 'Old'),
        record('3k33', '2026-03-12T10:00:00.000Z', 'New'),
        record('3k22', '2026-03-11T10:00:00.000Z', 'Middle'),
      ],
    });
  });

  it('lists my posts, newest first', async () => {
    const actual = await postListRaw({});

    expect(__.callApi).toHaveBeenCalledWith('com.atproto.repo.listRecords', {
      query: {
        repo: 'did:plc:me',
        collection: 'app.bsky.feed.post',
        limit: 25,
      },
    });
    expect(actual).toEqual(
      [
        'at://did:plc:me/app.bsky.feed.post/3k33▮2026-03-12T10:00:00.000Z▮New',
        'at://did:plc:me/app.bsky.feed.post/3k22▮2026-03-11T10:00:00.000Z▮Middle',
        'at://did:plc:me/app.bsky.feed.post/3k11▮2026-03-10T10:00:00.000Z▮Old',
      ].join('\n'),
    );
  });

  it('returns at most the limit, as a string from the command line', async () => {
    const actual = await postListRaw({ limit: '2' });

    expect(__.callApi).toHaveBeenCalledWith('com.atproto.repo.listRecords', {
      query: { repo: 'did:plc:me', collection: 'app.bsky.feed.post', limit: 2 },
    });
    expect(actual).toEqual(
      [
        'at://did:plc:me/app.bsky.feed.post/3k33▮2026-03-12T10:00:00.000Z▮New',
        'at://did:plc:me/app.bsky.feed.post/3k22▮2026-03-11T10:00:00.000Z▮Middle',
      ].join('\n'),
    );
  });

  it('keeps the text on one line, without separators', async () => {
    __.callApi.mockReturnValue({
      records: [record('3k33', '2026-03-12T10:00:00.000Z', 'One\nTwo ▮ ▯')],
    });

    const actual = await postListRaw({});

    expect(actual).toEqual(
      'at://did:plc:me/app.bsky.feed.post/3k33▮2026-03-12T10:00:00.000Z▮One Two  ',
    );
  });

  it('returns an empty string when there is no post', async () => {
    __.callApi.mockReturnValue({ records: [] });

    const actual = await postListRaw({});

    expect(actual).toEqual('');
  });

  describe('with an actor', () => {
    const feedItem = (rkey, createdAt, text, reason) => {
      return {
        post: {
          uri: `at://did:plc:you/app.bsky.feed.post/${rkey}`,
          record: { text, createdAt },
        },
        ...(reason && { reason }),
      };
    };

    beforeEach(() => {
      __.callPublicApi.mockReturnValue({
        feed: [
          feedItem('3k33', '2026-03-12T10:00:00.000Z', 'New'),
          feedItem('3k99', '2026-03-13T10:00:00.000Z', 'Repost', {
            $type: 'app.bsky.feed.defs#reasonRepost',
          }),
          feedItem('3k22', '2026-03-11T10:00:00.000Z', 'Middle'),
        ],
      });
    });

    it('lists the posts of the actor, without reposts, and without login', async () => {
      const actual = await postListRaw({ actor: 'you.dev', limit: '2' });

      expect(__.callPublicApi).toHaveBeenCalledWith(
        'app.bsky.feed.getAuthorFeed',
        {
          query: {
            actor: 'you.dev',
            filter: 'posts_no_replies',
            limit: 2,
          },
        },
      );
      expect(__.getConfig).not.toHaveBeenCalled();
      expect(__.callApi).not.toHaveBeenCalled();
      expect(actual).toEqual(
        [
          'at://did:plc:you/app.bsky.feed.post/3k33▮2026-03-12T10:00:00.000Z▮New',
          'at://did:plc:you/app.bsky.feed.post/3k22▮2026-03-11T10:00:00.000Z▮Middle',
        ].join('\n'),
      );
    });

    it('removes the @ typed before the handle', async () => {
      await postListRaw({ actor: '@you.dev' });

      expect(__.callPublicApi).toHaveBeenCalledWith(
        'app.bsky.feed.getAuthorFeed',
        { query: expect.objectContaining({ actor: 'you.dev' }) },
      );
    });
  });

  it.each([
    { title: 'zero', limit: '0' },
    { title: 'a negative number', limit: '-1' },
    { title: 'a decimal', limit: '1.5' },
    { title: 'text', limit: 'abc' },
    { title: 'an empty string', limit: '' },
    { title: 'more than the API accepts', limit: '101' },
  ])('fails before calling the API with $title', async ({ limit }) => {
    let actual = null;
    try {
      await postListRaw({ limit });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_INVALID_ARGUMENT');
    expect(__.callApi).not.toHaveBeenCalled();
    expect(__.getConfig).not.toHaveBeenCalled();
  });
});
