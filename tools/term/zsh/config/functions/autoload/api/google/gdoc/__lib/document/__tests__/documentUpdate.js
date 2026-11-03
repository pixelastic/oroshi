import { __, documentUpdate } from '../documentUpdate.js';

describe('documentUpdate', () => {
  const docx = Buffer.from('docx content');

  // The request sent to uploadDocx
  const getRequest = () => __.uploadDocx.mock.calls[0][0];

  beforeEach(() => {
    vi.spyOn(__, 'readDocx').mockReturnValue(docx);
    vi.spyOn(__, 'uploadDocx').mockReturnValue({
      id: 'docA',
      name: 'Old Title',
    });
    vi.spyOn(__, 'documentSetPageless').mockReturnValue();
    vi.spyOn(__, 'formatDocument').mockReturnValue({ id: 'formatted' });
  });

  it('patches the existing file, so the ID stays', async () => {
    await documentUpdate({
      documentId: 'https://docs.google.com/document/d/docA/edit',
      filepath: '/path/to/article.md',
    });

    expect(__.readDocx).toHaveBeenCalledWith('/path/to/article.md');
    expect(getRequest()).toMatchObject({
      path: 'files/docA',
      method: 'PATCH',
      content: docx,
    });
  });

  it('keeps the title without --title', async () => {
    await documentUpdate({
      documentId: 'docA',
      filepath: '/path/to/article.md',
    });

    const { metadata } = getRequest();
    expect(metadata).not.toHaveProperty('name');
    expect(metadata).toHaveProperty(
      'mimeType',
      'application/vnd.google-apps.document',
    );
  });

  it('renames the Document with --title', async () => {
    await documentUpdate({
      documentId: 'docA',
      filepath: '/path/to/article.md',
      title: 'New Title',
    });

    expect(getRequest().metadata).toHaveProperty('name', 'New Title');
  });

  it('switches the Document to pageless', async () => {
    await documentUpdate({
      documentId: 'docA',
      filepath: '/path/to/article.md',
    });

    expect(__.documentSetPageless).toHaveBeenCalledWith('docA');
  });

  it('returns the updated Document, formatted', async () => {
    const actual = await documentUpdate({
      documentId: 'docA',
      filepath: '/path/to/article.md',
    });

    expect(__.formatDocument).toHaveBeenCalledWith({
      documentId: 'docA',
      title: 'Old Title',
    });
    expect(actual).toEqual({ id: 'formatted' });
  });

  it('throws GDOC_DOCUMENT_ID_MISSING when no Document is given', async () => {
    let actual = null;
    try {
      await documentUpdate({ filepath: '/path/to/article.md' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GDOC_DOCUMENT_ID_MISSING');
    expect(__.uploadDocx).not.toHaveBeenCalled();
  });

  it('does not upload when the file cannot be read', async () => {
    __.readDocx.mockImplementation(() => {
      throw new Error('GDOC_FILE_UNSUPPORTED');
    });

    let actual = null;
    try {
      await documentUpdate({ documentId: 'docA', filepath: '/notes.txt' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'GDOC_FILE_UNSUPPORTED');
    expect(__.uploadDocx).not.toHaveBeenCalled();
  });
});
