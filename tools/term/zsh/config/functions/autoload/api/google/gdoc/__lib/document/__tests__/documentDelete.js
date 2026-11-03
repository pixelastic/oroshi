import { __, documentDelete } from '../documentDelete.js';

describe('documentDelete', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      id: 'abc123',
      name: 'article',
      trashed: true,
    });
    vi.spyOn(__, 'formatDocument').mockReturnValue({ id: 'formatted' });
  });

  it('sends trashed: true to the Drive file of the given id', async () => {
    await documentDelete({ documentId: 'abc123' });

    expect(__.callApi).toHaveBeenCalledWith('files/abc123', {
      baseUrl: 'https://www.googleapis.com/drive/v3',
      method: 'PATCH',
      query: { fields: 'id,name,trashed' },
      body: { trashed: true },
    });
  });

  it('never calls the Drive delete endpoint', async () => {
    await documentDelete({ documentId: 'abc123' });

    expect(__.callApi).toHaveBeenCalledTimes(1);
    expect(__.callApi.mock.calls[0][1]).not.toHaveProperty('method', 'DELETE');
  });

  it('extracts the id from a Document URL', async () => {
    await documentDelete({
      documentId: 'https://docs.google.com/document/d/abc123/edit?tab=t.0',
    });

    expect(__).toHaveProperty('callApi.mock.calls.0.0', 'files/abc123');
  });

  it('throws when no Document is given', async () => {
    let actual = null;
    try {
      await documentDelete({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GDOC_DOCUMENT_ID_MISSING');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('returns the Document, formatted, with trashed: true', async () => {
    const actual = await documentDelete({ documentId: 'abc123' });

    expect(__.formatDocument).toHaveBeenCalledWith({
      documentId: 'abc123',
      title: 'article',
    });
    expect(actual).toEqual({ id: 'formatted', trashed: true });
  });
});
