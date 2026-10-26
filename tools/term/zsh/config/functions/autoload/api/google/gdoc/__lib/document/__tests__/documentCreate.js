import { __, documentCreate } from '../documentCreate.js';

describe('documentCreate', () => {
  // Content of the file that is uploaded, from a Markdown or a docx source
  const docxFromMarkdown = Buffer.from('docx from markdown');
  const docxAsIs = Buffer.from('docx as is');

  // The request sent to the upload endpoint
  const getRequest = () => __.callApi.mock.calls[0];
  const getBody = async () => await getRequest()[1].body.text();

  beforeEach(() => {
    vi.spyOn(__, 'getConfig').mockReturnValue({
      docsFolderId: 'folderDefault',
      referenceDoc: '/config/reference.docx',
    });
    vi.spyOn(__, 'callApi').mockReturnValue({ id: 'docA', name: 'article' });
    vi.spyOn(__, 'markdownToDocx').mockReturnValue(docxFromMarkdown);
    vi.spyOn(__, 'readFile').mockReturnValue(docxAsIs);
    vi.spyOn(__, 'documentSetPageless').mockReturnValue();
    vi.spyOn(__, 'formatDocument').mockReturnValue({ id: 'formatted' });
  });

  it('converts a .md file with pandoc, uploads it and switches to pageless', async () => {
    await documentCreate({ filepath: '/path/to/article.md' });

    expect(__.markdownToDocx).toHaveBeenCalledWith(
      '/path/to/article.md',
      '/config/reference.docx',
    );
    expect(await getBody()).toContain('docx from markdown');
    expect(__.documentSetPageless).toHaveBeenCalledWith('docA');
  });

  it('uploads a .docx file as is, without pandoc', async () => {
    await documentCreate({ filepath: '/path/to/article.docx' });

    expect(__.markdownToDocx).not.toHaveBeenCalled();
    expect(__.readFile).toHaveBeenCalledWith('/path/to/article.docx');
    expect(await getBody()).toContain('docx as is');
  });

  it('sends the upload to the Drive upload endpoint, converted to a Google Doc', async () => {
    await documentCreate({ filepath: '/path/to/article.md' });

    const [path, options] = getRequest();
    expect(path).toEqual('files');
    expect(options).toMatchObject({
      baseUrl: 'https://www.googleapis.com/upload/drive/v3',
      method: 'POST',
      query: { uploadType: 'multipart', fields: 'id,name' },
    });
  });

  it('sends a multipart request with the metadata part, then the file part', async () => {
    await documentCreate({ filepath: '/path/to/article.md' });

    const { headers } = getRequest()[1];
    const boundary = headers['Content-Type'].match(
      /^multipart\/related; boundary=(.+)$/,
    )[1];
    const body = await getBody();
    const [, metadataPart, filePart] = body.split(`--${boundary}`);

    expect(body.trimEnd().endsWith(`--${boundary}--`)).toEqual(true);
    expect(metadataPart).toContain('Content-Type: application/json');
    expect(metadataPart).toContain('"name":"article"');
    expect(filePart).toContain(
      'Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );
    expect(filePart).toContain('docx from markdown');
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

    const metadata = JSON.parse(
      (await getBody()).match(/application\/json[^\r\n]*\r\n\r\n(.+)\r\n/)[1],
    );
    expect(metadata).toMatchObject({
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

    const body = await getBody();
    const metadata = JSON.parse(body.match(/\r\n\r\n(\{.+\})\r\n/)[1]);
    expect(metadata).toHaveProperty('parents', expected);
  });

  it('puts the Document at the root of the Drive without any folder', async () => {
    __.getConfig.mockReturnValue({ referenceDoc: '/config/reference.docx' });

    await documentCreate({ filepath: '/path/to/article.md' });

    const body = await getBody();
    const metadata = JSON.parse(body.match(/\r\n\r\n(\{.+\})\r\n/)[1]);
    expect(metadata).not.toHaveProperty('parents');
  });

  it('returns the created Document, formatted', async () => {
    const actual = await documentCreate({ filepath: '/path/to/article.md' });

    expect(__.formatDocument).toHaveBeenCalledWith({
      documentId: 'docA',
      title: 'article',
    });
    expect(actual).toEqual({ id: 'formatted' });
  });

  it.each([
    {
      title: 'no file',
      options: {},
      expected: 'GDOC_FILE_MISSING',
    },
    {
      title: 'an unsupported file',
      options: { filepath: '/path/to/notes.txt' },
      expected: 'GDOC_FILE_UNSUPPORTED',
    },
  ])('throws $expected on $title', async ({ options, expected }) => {
    let actual = null;
    try {
      await documentCreate(options);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', expected);
    expect(__.callApi).not.toHaveBeenCalled();
  });
});

describe('markdownToDocx', () => {
  beforeEach(() => {
    vi.spyOn(__, 'run').mockReturnValue();
    vi.spyOn(__, 'mkdirp').mockReturnValue();
    vi.spyOn(__, 'remove').mockReturnValue();
    vi.spyOn(__, 'readFile').mockReturnValue(Buffer.from('docx'));
  });

  it('runs pandoc with the reference document, from the folder of the file', async () => {
    await __.markdownToDocx('/path/to/article.md', '/config/reference.docx');

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
    await __.markdownToDocx('article.md', '/config/reference.docx');

    const [command, options] = __.run.mock.calls[0];
    expect(command).toContain(`${process.cwd()}/article.md`);
    expect(options).toMatchObject({ cwd: process.cwd() });
  });

  it('returns the content of the docx and removes the temporary directory', async () => {
    const actual = await __.markdownToDocx(
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
      await __.markdownToDocx('/path/to/article.md', '/config/reference.docx');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'pandoc failed');
    expect(__.remove).toHaveBeenCalled();
  });
});
