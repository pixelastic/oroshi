import { __, documentAppend } from '../documentAppend.js';

describe('documentAppend', () => {
  const docx = Buffer.from('docx content');
  const target = {
    title: 'Target Title',
    body: { content: [{ endIndex: 1 }, { endIndex: 20 }] },
  };
  const converted = { title: 'Temporary', body: { content: [] } };
  const requests = [{ insertText: {} }];

  // The request sent to uploadDocx
  const getUpload = () => __.uploadDocx.mock.calls[0][0];

  beforeEach(() => {
    vi.spyOn(__, 'contentToDocx').mockReturnValue(docx);
    vi.spyOn(__, 'uploadDocx').mockReturnValue({ id: 'tempDoc', name: 'T' });
    vi.spyOn(__, 'callApi').mockImplementation((path) => {
      if (path === 'documents/docA') {
        return target;
      }
      if (path === 'documents/tempDoc') {
        return converted;
      }
      return {};
    });
    vi.spyOn(__, 'buildAppendRequests').mockReturnValue(requests);
    vi.spyOn(__, 'documentDelete').mockReturnValue({});
    vi.spyOn(__, 'formatDocument').mockReturnValue({ id: 'formatted' });
  });

  it('imports the content as a temporary Document', async () => {
    await documentAppend({
      documentId: 'https://docs.google.com/document/d/docA/edit',
      content: '# Title',
    });

    expect(__.contentToDocx).toHaveBeenCalledWith({
      content: '# Title',
      contentFile: undefined,
    });
    expect(getUpload()).toMatchObject({
      path: 'files',
      method: 'POST',
      content: docx,
    });
  });

  it('adds the converted content at the end of the Document', async () => {
    await documentAppend({ documentId: 'docA', content: '# Title' });

    expect(__.buildAppendRequests).toHaveBeenCalledWith(converted, 20);
    expect(__.callApi).toHaveBeenLastCalledWith('documents/docA:batchUpdate', {
      method: 'POST',
      body: { requests },
    });
  });

  it('trashes the temporary Document', async () => {
    await documentAppend({ documentId: 'docA', content: '# Title' });

    expect(__.documentDelete).toHaveBeenCalledWith({ documentId: 'tempDoc' });
  });

  it('trashes the temporary Document when the copy fails', async () => {
    __.callApi.mockImplementation((path) => {
      if (path === 'documents/docA:batchUpdate') {
        throw new Error('GDOC_COPY_FAILED');
      }
      return path === 'documents/docA' ? target : converted;
    });

    let actual = null;
    try {
      await documentAppend({ documentId: 'docA', content: '# Title' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'GDOC_COPY_FAILED');
    expect(__.documentDelete).toHaveBeenCalledWith({ documentId: 'tempDoc' });
  });

  it('returns the Document, formatted', async () => {
    const actual = await documentAppend({
      documentId: 'docA',
      content: '# Title',
    });

    expect(__.formatDocument).toHaveBeenCalledWith({
      documentId: 'docA',
      title: 'Target Title',
    });
    expect(actual).toEqual({ id: 'formatted' });
  });

  it.each([
    {
      title: 'GDOC_CONTENT_MISSING when no content is given',
      input: { documentId: 'docA' },
      expected: 'GDOC_CONTENT_MISSING',
    },
    {
      title: 'GDOC_DOCUMENT_ID_MISSING when no Document is given',
      input: { content: '# Title' },
      expected: 'GDOC_DOCUMENT_ID_MISSING',
    },
  ])('throws $title', async ({ input, expected }) => {
    let actual = null;
    try {
      await documentAppend(input);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', expected);
    expect(__.uploadDocx).not.toHaveBeenCalled();
  });

  it('creates no temporary Document when the Document cannot be read', async () => {
    __.callApi.mockImplementation(() => {
      throw new Error('GDOC_NOT_FOUND');
    });

    let actual = null;
    try {
      await documentAppend({ documentId: 'docA', content: '# Title' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'GDOC_NOT_FOUND');
    expect(__.uploadDocx).not.toHaveBeenCalled();
  });
});

describe('documentAppend contentToDocx', () => {
  beforeEach(() => {
    vi.spyOn(__, 'tmpDirectory').mockReturnValue('/tmp/append');
    vi.spyOn(__, 'write').mockReturnValue();
    vi.spyOn(__, 'remove').mockReturnValue();
    vi.spyOn(__, 'readDocx').mockReturnValue(Buffer.from('docx'));
  });

  it('converts a content file as is', async () => {
    const actual = await __.contentToDocx({ contentFile: '/path/note.md' });

    expect(__.readDocx).toHaveBeenCalledWith('/path/note.md');
    expect(__.write).not.toHaveBeenCalled();
    expect(actual).toEqual(Buffer.from('docx'));
  });

  it('converts an inline content through a temporary file', async () => {
    const actual = await __.contentToDocx({ content: '# Title' });

    expect(__.write).toHaveBeenCalledWith('# Title', '/tmp/append/content.md');
    expect(__.readDocx).toHaveBeenCalledWith('/tmp/append/content.md');
    expect(__.remove).toHaveBeenCalledWith('/tmp/append');
    expect(actual).toEqual(Buffer.from('docx'));
  });

  it('prefers the content file', async () => {
    await __.contentToDocx({ content: '# Title', contentFile: '/note.md' });

    expect(__.readDocx).toHaveBeenCalledWith('/note.md');
  });
});
