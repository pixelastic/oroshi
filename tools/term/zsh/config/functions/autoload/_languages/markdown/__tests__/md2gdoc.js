import { __, md2gdoc } from '../__lib/md2gdoc.js';

describe('md2gdoc', () => {
  beforeEach(() => {
    vi.spyOn(__, 'runPandoc').mockReturnValue();
    vi.spyOn(__, 'googleAuth').mockReturnValue({ credentials: 'mock' });
    vi.spyOn(__, 'uploadDoc').mockReturnValue('mock-doc-id-456');
    vi.spyOn(__, 'setPageless').mockReturnValue();
    vi.spyOn(__, 'openBrowser').mockReturnValue();
    vi.spyOn(__, 'cleanup').mockReturnValue();
  });

  it('calls Pandoc with input path, output DOCX, and cwd', async () => {
    await md2gdoc('/path/to/article.md');
    expect(__.runPandoc).toHaveBeenCalledWith(
      '/path/to/article.md',
      '/tmp/oroshi/md2gdoc/article.docx',
      '/path/to',
    );
  });

  it('uploads with DOCX mimeType', async () => {
    await md2gdoc('/path/to/file.md');
    expect(__.uploadDoc).toHaveBeenCalledWith(
      expect.anything(),
      'file',
      '/tmp/oroshi/md2gdoc/file.docx',
    );
  });

  it.each([
    {
      title: 'default title from filename',
      filepath: '/path/to/my-article.md',
      options: {},
      expected: 'my-article',
    },
    {
      title: 'custom title via --title',
      filepath: '/path/to/file.md',
      options: { title: 'Custom' },
      expected: 'Custom',
    },
  ])('$title', async ({ filepath, options, expected }) => {
    await md2gdoc(filepath, options);
    expect(__.uploadDoc).toHaveBeenCalledWith(
      expect.anything(),
      expected,
      expect.anything(),
    );
  });

  it('returns Google Docs URL', async () => {
    const actual = await md2gdoc('/path/to/file.md');
    expect(actual).toEqual(
      'https://docs.google.com/document/d/mock-doc-id-456/edit',
    );
  });

  it('opens browser with the Doc URL by default', async () => {
    await md2gdoc('/path/to/file.md');
    expect(__.openBrowser).toHaveBeenCalledWith(
      'https://docs.google.com/document/d/mock-doc-id-456/edit',
    );
  });

  it('skips browser when open is false', async () => {
    await md2gdoc('/path/to/file.md', { open: false });
    expect(__.openBrowser).not.toHaveBeenCalled();
  });

  it('switches doc to pageless mode after upload', async () => {
    await md2gdoc('/path/to/file.md');
    expect(__.setPageless).toHaveBeenCalledWith(
      { credentials: 'mock' },
      'mock-doc-id-456',
    );
  });

  it('cleans up temp directory after upload', async () => {
    await md2gdoc('/path/to/file.md');
    expect(__.cleanup).toHaveBeenCalled();
  });
});

describe('runPandoc', () => {
  beforeEach(() => {
    vi.spyOn(__, 'mkdirp').mockReturnValue();
    vi.spyOn(__, 'run').mockReturnValue();
    vi.stubEnv('OROSHI_MD2GDOC_REFERENCE_DOC', '/config/reference.docx');
  });

  afterEach(() => {
    vi.unstubAllEnvs();
  });

  it('calls pandoc with reference-doc and extract-media flags', async () => {
    await __.runPandoc(
      '/path/to/file.md',
      '/tmp/oroshi/md2gdoc/file.docx',
      '/path/to',
    );
    const command = __.run.mock.calls[0][0];
    expect(command).toContain('--reference-doc=');
    expect(command).toContain('reference.docx');
    expect(command).toContain('--extract-media=/tmp/oroshi/md2gdoc/');
    expect(command).toContain('-o "/tmp/oroshi/md2gdoc/file.docx"');
  });

  it('runs pandoc with cwd set to source directory', async () => {
    await __.runPandoc(
      '/path/to/file.md',
      '/tmp/oroshi/md2gdoc/file.docx',
      '/path/to',
    );
    const options = __.run.mock.calls[0][1];
    expect(options).toEqual(expect.objectContaining({ cwd: '/path/to' }));
  });
});

describe('setPageless', () => {
  it('sends batchUpdate with PAGELESS documentMode', async () => {
    const mockBatchUpdate = vi.fn().mockReturnValue({});
    vi.spyOn(__.google, 'docs').mockReturnValue({
      documents: { batchUpdate: mockBatchUpdate },
    });

    await __.setPageless({ credentials: 'mock' }, 'doc-123');

    const callArgs = mockBatchUpdate.mock.calls[0][0];
    expect(callArgs).toHaveProperty('documentId', 'doc-123');
    const request = callArgs.requestBody.requests[0].updateDocumentStyle;
    expect(request).toHaveProperty(
      'documentStyle.documentFormat.documentMode',
      'PAGELESS',
    );
  });
});

describe('uploadDoc', () => {
  it('uses DOCX mimeType for media upload', async () => {
    const mockCreate = vi.fn().mockReturnValue({ data: { id: 'abc' } });
    vi.spyOn(__.google, 'drive').mockReturnValue({
      files: { create: mockCreate },
    });
    vi.spyOn(__, 'createReadStream').mockReturnValue('mock-stream');

    await __.uploadDoc({ credentials: 'mock' }, 'title', '/tmp/file.docx');

    const callArgs = mockCreate.mock.calls[0][0];
    expect(callArgs).toHaveProperty(
      'media.mimeType',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );
  });
});
