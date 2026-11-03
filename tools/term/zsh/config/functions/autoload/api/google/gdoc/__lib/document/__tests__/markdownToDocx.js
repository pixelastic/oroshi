import { __, markdownToDocx } from '../markdownToDocx.js';

describe('markdownToDocx', () => {
  beforeEach(() => {
    vi.spyOn(__, 'run').mockReturnValue();
    vi.spyOn(__, 'mkdirp').mockReturnValue();
    vi.spyOn(__, 'remove').mockReturnValue();
    vi.spyOn(__, 'readFile').mockReturnValue(Buffer.from('docx'));
  });

  it('runs pandoc with the reference document, from the folder of the file', async () => {
    await markdownToDocx('/path/to/article.md', '/config/reference.docx');

    const [command, options] = __.run.mock.calls[0];
    expect(command).toContain('pandoc');
    expect(command).toContain('/path/to/article.md');
    expect(command).toContain('--reference-doc=/config/reference.docx');
    expect(command).toContain('-f');
    expect(command).toContain('markdown-auto_identifiers');
    expect(command.some((arg) => arg.startsWith('--extract-media='))).toEqual(
      true,
    );
    expect(options).toMatchObject({ cwd: '/path/to' });
  });

  it('resolves a relative path, because pandoc runs from the folder of the file', async () => {
    await markdownToDocx('article.md', '/config/reference.docx');

    const [command, options] = __.run.mock.calls[0];
    expect(command).toContain(`${process.cwd()}/article.md`);
    expect(options).toMatchObject({ cwd: process.cwd() });
  });

  it('returns the content of the docx and removes the temporary directory', async () => {
    const actual = await markdownToDocx(
      '/path/to/article.md',
      '/config/reference.docx',
    );

    expect(actual).toEqual(Buffer.from('docx'));
    const [directory] = __.remove.mock.calls[0];
    expect(__.readFile.mock.calls[0][0].startsWith(directory)).toEqual(true);
  });

  it('removes the temporary directory when pandoc fails', async () => {
    __.run.mockImplementation(() => {
      throw new Error('pandoc failed');
    });

    let actual = null;
    try {
      await markdownToDocx('/path/to/article.md', '/config/reference.docx');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'pandoc failed');
    expect(__.remove).toHaveBeenCalled();
  });
});
