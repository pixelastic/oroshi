import { __, readDraft } from '../readDraft.js';

describe('readDraft', () => {
  beforeEach(() => {
    vi.spyOn(__, 'read').mockReturnValue('# From file');
  });

  it('returns the inline text, named <text>', async () => {
    const actual = await readDraft({ text: 'Hello' });

    expect(actual).toEqual({ file: '<text>', markdown: 'Hello' });
  });

  it('returns the content of the file, which wins over the inline text', async () => {
    const actual = await readDraft({ text: 'Hello', textFile: '/tmp/a.md' });

    expect(__.read).toHaveBeenCalledWith('/tmp/a.md');
    expect(actual).toEqual({ file: '/tmp/a.md', markdown: '# From file' });
  });

  it.each([
    { title: 'nothing is given', options: {} },
    { title: 'the inline text is empty', options: { text: '' } },
  ])('fails with BLUESKY_MISSING_ARGUMENT when $title', async ({ options }) => {
    let actual = null;
    try {
      await readDraft(options);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_MISSING_ARGUMENT');
    expect(actual).toHaveProperty('message', 'Pass the --text or --text-file');
    expect(__.read).not.toHaveBeenCalled();
  });
});
