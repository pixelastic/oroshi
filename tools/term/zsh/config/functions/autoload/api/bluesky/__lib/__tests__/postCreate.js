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
      markdown: 'Hello',
    });
    vi.spyOn(__, 'parsePostMarkdown').mockReturnValue(posts);
    vi.spyOn(__, 'validatePost').mockReturnValue([]);
    vi.spyOn(__, 'getConfig').mockReturnValue({
      tokens: { sessions: { 'did:plc:abc': {} } },
    });
    vi.spyOn(__, 'callApi').mockReturnValue({ uri: 'at://x', cid: 'bafy' });
    vi.spyOn(__, 'formatPost').mockReturnValue({
      uri: 'at://x',
      url: 'https://y',
    });
    vi.spyOn(__, 'previewPosts').mockReturnValue([{ text: 'preview' }]);
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
    expect(__.parsePostMarkdown).toHaveBeenCalledWith('Hello');
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
