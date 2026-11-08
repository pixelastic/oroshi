import { __, postLint } from '../postLint.js';

describe('postLint', () => {
  const posts = [{ text: 'Hello', facets: [], line: 3 }];

  beforeEach(() => {
    vi.spyOn(__, 'readDraft').mockReturnValue({
      file: '<text>',
      markdown: 'Hello',
    });
    vi.spyOn(__, 'parsePostMarkdown').mockReturnValue(posts);
    vi.spyOn(__, 'validatePost').mockReturnValue([]);
  });

  it('reads the draft from the options', async () => {
    await postLint({ text: 'Hello', textFile: 'draft.md' });

    expect(__.readDraft).toHaveBeenCalledWith({
      text: 'Hello',
      textFile: 'draft.md',
    });
  });

  it('parses the Markdown of the draft', async () => {
    __.readDraft.mockReturnValue({
      file: '/tmp/a.md',
      markdown: '# From file',
    });

    await postLint({ textFile: '/tmp/a.md' });

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
    __.readDraft.mockReturnValue({ file: '/tmp/draft.md', markdown: '' });
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
});
