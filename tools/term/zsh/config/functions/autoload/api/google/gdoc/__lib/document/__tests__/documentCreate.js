import { __, documentCreate } from '../documentCreate.js';

describe('documentCreate', () => {
  const docx = Buffer.from('docx content');

  // The request sent to uploadDocx
  const getRequest = () => __.uploadDocx.mock.calls[0][0];

  beforeEach(() => {
    vi.spyOn(__, 'getConfig').mockReturnValue({
      docsFolderId: 'folderDefault',
    });
    vi.spyOn(__, 'readDocx').mockReturnValue(docx);
    vi.spyOn(__, 'uploadDocx').mockReturnValue({ id: 'docA', name: 'article' });
    vi.spyOn(__, 'documentSetPageless').mockReturnValue();
    vi.spyOn(__, 'formatDocument').mockReturnValue({ id: 'formatted' });
  });

  it('uploads the docx of the file as a new file, and switches to pageless', async () => {
    await documentCreate({ filepath: '/path/to/article.md' });

    expect(__.readDocx).toHaveBeenCalledWith('/path/to/article.md');
    expect(getRequest()).toMatchObject({
      path: 'files',
      method: 'POST',
      content: docx,
    });
    expect(__.documentSetPageless).toHaveBeenCalledWith('docA');
  });

  it.each([
    {
      title: 'the file name without extension by default',
      options: { filepath: '/path/to/my-article.md' },
      expected: 'my-article',
    },
    {
      title: 'the file name of a .docx without extension',
      options: { filepath: '/path/to/report.docx' },
      expected: 'report',
    },
    {
      title: '--title when passed',
      options: { filepath: '/path/to/my-article.md', title: 'Custom Title' },
      expected: 'Custom Title',
    },
  ])('names the Document with $title', async ({ options, expected }) => {
    await documentCreate(options);

    expect(getRequest().metadata).toMatchObject({
      name: expected,
      mimeType: 'application/vnd.google-apps.document',
    });
  });

  it.each([
    {
      title: 'the id parsed from a --directory URL',
      directory: 'https://drive.google.com/drive/u/0/folders/folderA?usp=x',
      expected: ['folderA'],
    },
    {
      title: 'a bare --directory id',
      directory: 'folderB',
      expected: ['folderB'],
    },
    {
      title: 'the configured folder without --directory',
      directory: undefined,
      expected: ['folderDefault'],
    },
  ])('puts the Document in $title', async ({ directory, expected }) => {
    await documentCreate({ filepath: '/path/to/article.md', directory });

    expect(getRequest().metadata).toHaveProperty('parents', expected);
  });

  it('puts the Document at the root of the Drive without any folder', async () => {
    __.getConfig.mockReturnValue({});

    await documentCreate({ filepath: '/path/to/article.md' });

    expect(getRequest().metadata).not.toHaveProperty('parents');
  });

  it('returns the created Document, formatted', async () => {
    const actual = await documentCreate({ filepath: '/path/to/article.md' });

    expect(__.formatDocument).toHaveBeenCalledWith({
      documentId: 'docA',
      title: 'article',
    });
    expect(actual).toEqual({ id: 'formatted' });
  });

  it('does not upload when the file cannot be read', async () => {
    __.readDocx.mockImplementation(() => {
      throw new Error('GDOC_FILE_MISSING');
    });

    let actual = null;
    try {
      await documentCreate({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'GDOC_FILE_MISSING');
    expect(__.uploadDocx).not.toHaveBeenCalled();
  });
});
