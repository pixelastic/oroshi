import { run } from 'firost';
import { google } from 'googleapis';
import { __, md2gdocs } from '../__lib/md2gdocs.js';

vi.mock('node:fs', () => ({
  createReadStream: vi.fn().mockReturnValue('mock-stream'),
}));

vi.mock('firost', () => ({
  mkdirp: vi.fn(),
  remove: vi.fn(),
  run: vi.fn(),
}));

vi.mock('googleapis', () => ({
  google: {
    drive: vi.fn(),
    docs: vi.fn(),
  },
}));

describe('md2gdocs', () => {
  beforeEach(() => {
    vi.spyOn(__, 'runPandoc').mockReturnValue();
    vi.spyOn(__, 'getAuth').mockReturnValue({ credentials: 'mock' });
    vi.spyOn(__, 'uploadDoc').mockReturnValue('mock-doc-id-456');
    vi.spyOn(__, 'setPageless').mockReturnValue();
    vi.spyOn(__, 'openBrowser').mockReturnValue();
    vi.spyOn(__, 'cleanup').mockReturnValue();
  });

  it('calls Pandoc with input path, output DOCX, and cwd', async () => {
    await md2gdocs('/path/to/article.md');
    expect(__.runPandoc).toHaveBeenCalledWith(
      '/path/to/article.md',
      '/tmp/oroshi/md2gdocs/article.docx',
      '/path/to',
    );
  });

  it('uploads with DOCX mimeType', async () => {
    await md2gdocs('/path/to/file.md');
    expect(__.uploadDoc).toHaveBeenCalledWith(
      expect.anything(),
      'file',
      '/tmp/oroshi/md2gdocs/file.docx',
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
    await md2gdocs(filepath, options);
    expect(__.uploadDoc).toHaveBeenCalledWith(
      expect.anything(),
      expected,
      expect.anything(),
    );
  });

  it('returns Google Docs URL', async () => {
    const actual = await md2gdocs('/path/to/file.md');
    expect(actual).toEqual(
      'https://docs.google.com/document/d/mock-doc-id-456/edit',
    );
  });

  it('opens browser with the Doc URL by default', async () => {
    await md2gdocs('/path/to/file.md');
    expect(__.openBrowser).toHaveBeenCalledWith(
      'https://docs.google.com/document/d/mock-doc-id-456/edit',
    );
  });

  it('skips browser when open is false', async () => {
    await md2gdocs('/path/to/file.md', { open: false });
    expect(__.openBrowser).not.toHaveBeenCalled();
  });

  it('switches doc to pageless mode after upload', async () => {
    await md2gdocs('/path/to/file.md');
    expect(__.setPageless).toHaveBeenCalledWith(
      { credentials: 'mock' },
      'mock-doc-id-456',
    );
  });

  it('cleans up temp directory after upload', async () => {
    await md2gdocs('/path/to/file.md');
    expect(__.cleanup).toHaveBeenCalled();
  });
});

describe('runPandoc', () => {
  it('calls pandoc with reference-doc and extract-media flags', async () => {
    await __.runPandoc(
      '/path/to/file.md',
      '/tmp/oroshi/md2gdocs/file.docx',
      '/path/to',
    );
    const command = run.mock.calls[0][0];
    expect(command).toContain('--reference-doc=');
    expect(command).toContain('reference.docx');
    expect(command).toContain('--extract-media=/tmp/oroshi/md2gdocs/');
    expect(command).toContain('-o "/tmp/oroshi/md2gdocs/file.docx"');
  });

  it('runs pandoc with cwd set to source directory', async () => {
    await __.runPandoc(
      '/path/to/file.md',
      '/tmp/oroshi/md2gdocs/file.docx',
      '/path/to',
    );
    const options = run.mock.calls[0][1];
    expect(options).toEqual(expect.objectContaining({ cwd: '/path/to' }));
  });
});

describe('setPageless', () => {
  it('sends batchUpdate with PAGELESS documentMode', async () => {
    const mockBatchUpdate = vi.fn().mockReturnValue({});
    google.docs.mockReturnValue({
      documents: { batchUpdate: mockBatchUpdate },
    });

    await __.setPageless({ credentials: 'mock' }, 'doc-123');

    const callArgs = mockBatchUpdate.mock.calls[0][0];
    expect(callArgs.documentId).toEqual('doc-123');
    const request = callArgs.requestBody.requests[0].updateDocumentStyle;
    expect(request.documentStyle.documentFormat.documentMode).toEqual(
      'PAGELESS',
    );
  });
});

describe('uploadDoc', () => {
  it('uses DOCX mimeType for media upload', async () => {
    const mockCreate = vi.fn().mockReturnValue({ data: { id: 'abc' } });
    google.drive.mockReturnValue({ files: { create: mockCreate } });

    await __.uploadDoc({ credentials: 'mock' }, 'title', '/tmp/file.docx');

    const callArgs = mockCreate.mock.calls[0][0];
    expect(callArgs.media.mimeType).toEqual(
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );
  });
});
