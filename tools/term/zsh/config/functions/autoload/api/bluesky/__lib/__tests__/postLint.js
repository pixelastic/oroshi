import { __, postLint } from '../postLint.js';

describe('postLint', () => {
  const posts = [{ text: 'Hello', facets: [], line: 3 }];

  beforeEach(() => {
    vi.spyOn(__, 'read').mockReturnValue('# From file');
    vi.spyOn(__, 'parsePostMarkdown').mockReturnValue(posts);
    vi.spyOn(__, 'validatePost').mockReturnValue([]);
  });

  it('parses the inline text', async () => {
    await postLint({ text: 'Hello' });

    expect(__.parsePostMarkdown).toHaveBeenCalledWith('Hello');
  });

  it('parses the content of the file, which wins over the inline text', async () => {
    await postLint({ text: 'Hello', textFile: 'draft.md' });

    expect(__.read).toHaveBeenCalledWith(expect.stringMatching(/draft\.md$/));
    expect(__.parsePostMarkdown).toHaveBeenCalledWith('# From file');
  });

  it('validates the parsed posts', async () => {
    await postLint({ text: 'Hello' });

    expect(__.validatePost).toHaveBeenCalledWith(posts);
  });

  it('returns an empty array for a clean draft', async () => {
    const actual = await postLint({ text: 'Hello' });

    expect(actual).toEqual([]);
  });

  it('returns each violation in the unified lint shape, with its file', async () => {
    __.validatePost.mockReturnValue([
      { code: 'empty', level: 'error', line: 3, message: 'No text' },
    ]);

    const actual = await postLint({ textFile: '/tmp/draft.md' });

    expect(actual).toEqual([
      {
        file: '/tmp/draft.md',
        code: 'empty',
        level: 'error',
        line: 3,
        endLine: 3,
        column: 1,
        endColumn: 1,
        message: 'No text',
      },
    ]);
  });

  it('names the inline text as the file of its violations', async () => {
    __.validatePost.mockReturnValue([
      { code: 'empty', level: 'error', line: 1, message: 'No text' },
    ]);

    const actual = await postLint({ text: ' ' });

    expect(actual).toHaveProperty('0.file', '<text>');
  });

  it.each([
    { title: 'nothing is given', options: {} },
    { title: 'the inline text is empty', options: { text: '' } },
  ])('fails with BLUESKY_MISSING_ARGUMENT when $title', async ({ options }) => {
    let actual = null;
    try {
      await postLint(options);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_MISSING_ARGUMENT');
    expect(actual).toHaveProperty('message', 'Pass the --text or --text-file');
    expect(__.parsePostMarkdown).not.toHaveBeenCalled();
  });
});
