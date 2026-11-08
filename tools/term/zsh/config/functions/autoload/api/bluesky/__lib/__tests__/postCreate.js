import { firostError } from 'firost';
import { __, postCreate } from '../postCreate.js';

describe('postCreate', () => {
  const facets = [
    {
      index: { byteStart: 0, byteEnd: 5 },
      features: [{ $type: 'app.bsky.richtext.facet#tag', tag: 'a' }],
    },
  ];
  const posts = [{ text: 'Hello', facets, line: 1 }];

  beforeEach(() => {
    vi.spyOn(__, 'readDraft').mockReturnValue({
      file: '<text>',
      directory: '/work',
      markdown: 'Hello',
    });
    vi.spyOn(__, 'parsePostMarkdown').mockReturnValue(posts);
    vi.spyOn(__, 'validatePost').mockReturnValue([]);
    vi.spyOn(__, 'resolveMentions').mockImplementation((input) => input);
    vi.spyOn(__, 'resolvePostRef').mockReturnValue(null);
    vi.spyOn(__, 'resolveLinkCards').mockImplementation((input) => input);
    vi.spyOn(__, 'uploadLinkCard').mockReturnValue({
      $type: 'app.bsky.embed.external',
      external: {},
    });
    vi.spyOn(__, 'getConfig').mockReturnValue({
      tokens: { sessions: { 'did:plc:abc': {} } },
    });
    vi.spyOn(__, 'callApi').mockReturnValue({ uri: 'at://x', cid: 'bafy' });
    vi.spyOn(__, 'formatPost').mockReturnValue({
      uri: 'at://x',
      url: 'https://y',
    });
    vi.spyOn(__, 'previewPosts').mockReturnValue([{ text: 'preview' }]);
    vi.spyOn(__, 'uploadImages').mockReturnValue({
      $type: 'app.bsky.embed.images',
      images: [],
    });
  });

  it('creates the record with the text and the facets', async () => {
    await postCreate({ text: 'Hello' });

    expect(__.callApi).toHaveBeenCalledWith('com.atproto.repo.createRecord', {
      method: 'POST',
      body: {
        repo: 'did:plc:abc',
        collection: 'app.bsky.feed.post',
        record: {
          $type: 'app.bsky.feed.post',
          text: 'Hello',
          facets,
          createdAt: expect.any(String),
        },
      },
    });
  });

  it('reads the draft from the options, where the file wins', async () => {
    await postCreate({ text: 'Hello', textFile: 'draft.md' });

    expect(__.readDraft).toHaveBeenCalledWith({
      text: 'Hello',
      textFile: 'draft.md',
    });
    expect(__.parsePostMarkdown).toHaveBeenCalledWith('Hello', {
      directory: '/work',
    });
  });

  it('returns the URI and the web URL of the created record', async () => {
    const actual = await postCreate({ text: 'Hello' });

    expect(__.formatPost).toHaveBeenCalledWith({ uri: 'at://x', cid: 'bafy' });
    expect(actual).toEqual({ uri: 'at://x', url: 'https://y' });
  });

  it('sends nothing and lists the violations when a post is invalid', async () => {
    __.validatePost.mockReturnValue([
      {
        code: 'empty',
        level: 'error',
        line: 3,
        message: 'The post has no text',
      },
      { code: 'too-long-bytes', level: 'error', line: 5, message: 'Too heavy' },
    ]);

    let actual = null;
    try {
      await postCreate({ text: ' ' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_INVALID_POST');
    expect(actual).toHaveProperty(
      'message',
      '<text>:3 empty The post has no text\n<text>:5 too-long-bytes Too heavy',
    );
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('ignores the warnings', async () => {
    __.validatePost.mockReturnValue([
      { code: 'image-heavy', level: 'warning', line: 1, message: 'Heavy' },
    ]);

    await postCreate({ text: 'Hello' });

    expect(__.callApi).toHaveBeenCalled();
  });

  it('sends nothing and returns the preview with --dry-run', async () => {
    const actual = await postCreate({ text: 'Hello', dryRun: true });

    expect(__.previewPosts).toHaveBeenCalledWith(posts);
    expect(actual).toEqual([{ text: 'preview' }]);
    expect(__.callApi).not.toHaveBeenCalled();
  });

  describe('with mentions', () => {
    const resolved = [
      {
        text: '@a.bsky.social',
        line: 1,
        facets: [
          {
            index: { byteStart: 0, byteEnd: 14 },
            features: [
              { $type: 'app.bsky.richtext.facet#mention', did: 'did:plc:a' },
            ],
          },
        ],
      },
    ];

    beforeEach(() => {
      __.resolveMentions.mockReturnValue(resolved);
    });

    it('creates the record with the DID of the mention', async () => {
      await postCreate({ text: '@a.bsky.social' });

      expect(__.resolveMentions).toHaveBeenCalledWith(posts);
      expect(__.callApi).toHaveBeenCalledWith(
        'com.atproto.repo.createRecord',
        expect.objectContaining({
          body: expect.objectContaining({
            record: expect.objectContaining({
              facets: resolved[0].facets,
            }),
          }),
        }),
      );
    });

    it('previews the resolved posts with --dry-run', async () => {
      await postCreate({ text: '@a.bsky.social', dryRun: true });

      expect(__.previewPosts).toHaveBeenCalledWith(resolved);
    });

    it('sends nothing when a handle does not resolve', async () => {
      __.resolveMentions.mockImplementation(() => {
        throw firostError('BLUESKY_UNKNOWN_HANDLE', 'unknown.bsky.social');
      });

      let actual = null;
      try {
        await postCreate({ text: '@unknown.bsky.social' });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'BLUESKY_UNKNOWN_HANDLE');
      expect(__.callApi).not.toHaveBeenCalled();
    });

    it('does not resolve when the post is invalid', async () => {
      __.validatePost.mockReturnValue([
        { code: 'empty', level: 'error', line: 1, message: 'No text' },
      ]);

      let actual = null;
      try {
        await postCreate({ text: ' ' });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'BLUESKY_INVALID_POST');
      expect(__.resolveMentions).not.toHaveBeenCalled();
    });
  });

  describe('with --reply-to', () => {
    const target = {
      uri: 'at://did:plc:abc/app.bsky.feed.post/3k44',
      cid: 'bafyTarget',
      text: 'Original',
      root: {
        uri: 'at://did:plc:root/app.bsky.feed.post/3k00',
        cid: 'bafyRoot',
      },
    };

    beforeEach(() => {
      vi.spyOn(__, 'resolvePostRef').mockReturnValue(target);
    });

    it('sets the root and the parent on the record', async () => {
      await postCreate({ text: 'Agreed', replyTo: 'https://bsky.app/x' });

      expect(__.resolvePostRef).toHaveBeenCalledWith('https://bsky.app/x');
      expect(__.callApi.mock.calls[0][1].body.record).toHaveProperty('reply', {
        root: target.root,
        parent: { uri: target.uri, cid: target.cid },
      });
    });

    it('uses the target as root and parent for a top-level post', async () => {
      const topLevel = {
        ...target,
        root: { uri: target.uri, cid: target.cid },
      };
      __.resolvePostRef.mockReturnValue(topLevel);

      await postCreate({ text: 'Agreed', replyTo: target.uri });

      const { reply } = __.callApi.mock.calls[0][1].body.record;
      expect(reply).toHaveProperty('root', reply.parent);
    });

    it('sends the target to the preview with --dry-run', async () => {
      await postCreate({ text: 'Agreed', replyTo: target.uri, dryRun: true });

      expect(__.previewPosts).toHaveBeenCalledWith([
        { ...posts[0], replyTo: target },
      ]);
      expect(__.callApi).not.toHaveBeenCalled();
    });

    it.each([
      { title: 'is invalid', replyTo: 'nope' },
      { title: 'is empty, so no top-level post goes out', replyTo: '' },
    ])('sends nothing when the reference $title', async ({ replyTo }) => {
      __.resolvePostRef.mockImplementation(() => {
        throw firostError('BLUESKY_INVALID_ARGUMENT', 'Invalid --reply-to');
      });

      let actual = null;
      try {
        await postCreate({ text: 'Agreed', replyTo });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'BLUESKY_INVALID_ARGUMENT');
      expect(__.resolvePostRef).toHaveBeenCalledWith(replyTo);
      expect(__.callApi).not.toHaveBeenCalled();
      expect(__.resolveMentions).not.toHaveBeenCalled();
    });

    it('does not resolve a target when the post is invalid', async () => {
      __.validatePost.mockReturnValue([
        { code: 'empty', level: 'error', line: 1, message: 'No text' },
      ]);

      let actual = null;
      try {
        await postCreate({ text: ' ', replyTo: target.uri });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'BLUESKY_INVALID_POST');
      expect(__.resolvePostRef).not.toHaveBeenCalled();
    });
  });

  it('adds no reply to the record without --reply-to', async () => {
    await postCreate({ text: 'Hello' });

    expect(__.callApi.mock.calls[0][1].body.record).not.toHaveProperty('reply');
  });

  describe('with images', () => {
    const images = [{ alt: 'A cat', path: '/work/cat.png', line: 1 }];
    const withImages = [{ text: 'Look', facets: [], images, line: 1 }];
    const embed = {
      $type: 'app.bsky.embed.images',
      images: [{ alt: 'A cat', image: { $type: 'blob' } }],
    };

    beforeEach(() => {
      __.resolveMentions.mockReturnValue(withImages);
      __.uploadImages.mockReturnValue(embed);
    });

    it('uploads the images and attaches the embed to the record', async () => {
      await postCreate({ text: 'Look' });

      expect(__.uploadImages).toHaveBeenCalledWith(images);
      expect(__.callApi).toHaveBeenCalledWith(
        'com.atproto.repo.createRecord',
        expect.objectContaining({
          body: expect.objectContaining({
            record: expect.objectContaining({ embed }),
          }),
        }),
      );
    });

    it('does not upload anything with --dry-run', async () => {
      await postCreate({ text: 'Look', dryRun: true });

      expect(__.previewPosts).toHaveBeenCalledWith(withImages);
      expect(__.uploadImages).not.toHaveBeenCalled();
    });

    it('uploads nothing when a post is invalid', async () => {
      __.validatePost.mockReturnValue([
        { code: 'image-not-found', level: 'error', line: 1, message: 'Gone' },
      ]);

      let actual = null;
      try {
        await postCreate({ text: 'Look' });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'BLUESKY_INVALID_POST');
      expect(__.uploadImages).not.toHaveBeenCalled();
    });

    it('fails with the missing alt error when an image has no alt', async () => {
      __.validatePost.mockReturnValue([
        { code: 'missing-alt', level: 'error', line: 3, message: 'No alt' },
      ]);

      let actual = null;
      try {
        await postCreate({ text: 'Look' });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'BLUESKY_MISSING_ALT');
      expect(actual).toHaveProperty('message', '<text>:3 missing-alt No alt');
      expect(__.uploadImages).not.toHaveBeenCalled();
    });
  });

  describe('with a link card', () => {
    const card = {
      uri: 'https://a.io',
      title: 'A',
      description: '',
      imageUrl: null,
    };
    const external = {
      $type: 'app.bsky.embed.external',
      external: { uri: 'https://a.io', title: 'A', description: '' },
    };
    const withCard = [
      { text: 'See', facets, images: [], card, warnings: [], line: 1 },
    ];

    beforeEach(() => {
      __.resolveLinkCards.mockReturnValue(withCard);
      __.uploadLinkCard.mockReturnValue(external);
    });

    it('resolves the cards of the posts, with the --no-embed option', async () => {
      await postCreate({ text: 'See', noEmbed: true });

      expect(__.resolveLinkCards).toHaveBeenCalledWith(posts, {
        noEmbed: true,
      });
    });

    it('uploads the card and attaches the external embed', async () => {
      await postCreate({ text: 'See' });

      expect(__.uploadLinkCard).toHaveBeenCalledWith(card);
      expect(__.uploadImages).not.toHaveBeenCalled();
      expect(__.callApi).toHaveBeenCalledWith(
        'com.atproto.repo.createRecord',
        expect.objectContaining({
          body: expect.objectContaining({
            record: expect.objectContaining({ embed: external }),
          }),
        }),
      );
    });

    it('attaches the images, not the card, when the post has both', async () => {
      const images = [{ alt: 'A cat', path: '/work/cat.png', line: 1 }];
      const imagesEmbed = { $type: 'app.bsky.embed.images', images: [] };
      __.resolveLinkCards.mockReturnValue([{ ...withCard[0], images }]);
      __.uploadImages.mockReturnValue(imagesEmbed);

      await postCreate({ text: 'See' });

      expect(__.uploadLinkCard).not.toHaveBeenCalled();
      expect(__).toHaveProperty(
        'callApi.mock.calls.0.1.body.record.embed',
        imagesEmbed,
      );
    });

    it('does not upload anything with --dry-run', async () => {
      await postCreate({ text: 'See', dryRun: true });

      expect(__.previewPosts).toHaveBeenCalledWith(withCard);
      expect(__.uploadLinkCard).not.toHaveBeenCalled();
    });

    it('publishes without a card, and returns the warning, when the page failed', async () => {
      __.resolveLinkCards.mockReturnValue([
        {
          ...withCard[0],
          card: null,
          warnings: ['1 Cannot fetch https://a.io'],
        },
      ]);

      const actual = await postCreate({ text: 'See' });

      expect(__.callApi.mock.calls[0][1].body.record).not.toHaveProperty(
        'embed',
      );
      expect(actual).toEqual({
        uri: 'at://x',
        url: 'https://y',
        warnings: ['1 Cannot fetch https://a.io'],
      });
    });
  });

  it('attaches no embed to a post without images', async () => {
    await postCreate({ text: 'Hello' });

    expect(__.uploadImages).not.toHaveBeenCalled();
    expect(__.callApi.mock.calls[0][1].body.record).not.toHaveProperty('embed');
  });

  it('still validates with --dry-run', async () => {
    __.validatePost.mockReturnValue([
      { code: 'empty', level: 'error', line: 1, message: 'No text' },
    ]);

    let actual = null;
    try {
      await postCreate({ text: ' ', dryRun: true });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_INVALID_POST');
  });

  it('fails with the missing argument error when there is no text', async () => {
    __.readDraft.mockImplementation(() => {
      throw firostError(
        'BLUESKY_MISSING_ARGUMENT',
        'Pass the --text or --text-file',
      );
    });

    let actual = null;
    try {
      await postCreate({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_MISSING_ARGUMENT');
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
