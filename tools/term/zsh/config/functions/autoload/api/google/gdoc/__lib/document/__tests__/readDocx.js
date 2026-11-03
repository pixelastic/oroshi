import { __, readDocx } from '../readDocx.js';

describe('readDocx', () => {
  beforeEach(() => {
    vi.spyOn(__, 'getConfig').mockReturnValue({
      referenceDoc: '/config/reference.docx',
    });
    vi.spyOn(__, 'markdownToDocx').mockReturnValue(
      Buffer.from('docx from markdown'),
    );
    vi.spyOn(__, 'readFile').mockReturnValue(Buffer.from('docx as is'));
  });

  it('converts a .md file with the reference doc', async () => {
    const actual = await readDocx('/path/to/article.md');

    expect(__.markdownToDocx).toHaveBeenCalledWith(
      '/path/to/article.md',
      '/config/reference.docx',
    );
    expect(actual).toEqual(Buffer.from('docx from markdown'));
  });

  it('reads a .docx file as is, without pandoc', async () => {
    const actual = await readDocx('/path/to/article.docx');

    expect(__.markdownToDocx).not.toHaveBeenCalled();
    expect(__.readFile).toHaveBeenCalledWith('/path/to/article.docx');
    expect(actual).toEqual(Buffer.from('docx as is'));
  });

  it.each([
    {
      title: 'no file',
      filepath: undefined,
      expected: 'GDOC_FILE_MISSING',
    },
    {
      title: 'an unsupported file',
      filepath: '/path/to/notes.txt',
      expected: 'GDOC_FILE_UNSUPPORTED',
    },
  ])('throws $expected on $title', async ({ filepath, expected }) => {
    let actual = null;
    try {
      await readDocx(filepath);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', expected);
    expect(__.markdownToDocx).not.toHaveBeenCalled();
    expect(__.readFile).not.toHaveBeenCalled();
  });
});
