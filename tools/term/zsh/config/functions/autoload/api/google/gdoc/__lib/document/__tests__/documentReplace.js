import { __, documentReplace } from '../documentReplace.js';

describe('documentReplace', () => {
  const doc = { title: 'Old Title', body: { content: [] } };

  // The requests sent in the batchUpdate call
  const getRequests = () => __.callApi.mock.calls[1][1].body.requests;

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue(doc);
    vi.spyOn(__, 'read').mockImplementation((path) => `content of ${path}`);
    vi.spyOn(__, 'findPassage').mockReturnValue({
      startIndex: 10,
      endIndex: 16,
    });
    vi.spyOn(__, 'parseInlineMarkdown').mockImplementation((markdown) => ({
      text: markdown,
      ranges: [],
    }));
    vi.spyOn(__, 'formatDocument').mockReturnValue({ id: 'formatted' });
  });

  it('replaces a unique passage in one request', async () => {
    await documentReplace({
      documentId: 'https://docs.google.com/document/d/docA/edit',
      old: 'Pariss',
      new: 'Paris',
    });

    expect(__.callApi).toHaveBeenCalledTimes(2);
    expect(__.callApi).toHaveBeenNthCalledWith(1, 'documents/docA');
    expect(__.findPassage).toHaveBeenCalledWith(doc, 'Pariss');
    expect(__.callApi).toHaveBeenNthCalledWith(
      2,
      'documents/docA:batchUpdate',
      {
        method: 'POST',
        body: {
          requests: [
            { deleteContentRange: { range: { startIndex: 10, endIndex: 16 } } },
            { insertText: { location: { index: 10 }, text: 'Paris' } },
          ],
        },
      },
    );
  });

  it('makes a word bold from the ranges of the new passage', async () => {
    __.parseInlineMarkdown.mockReturnValue({
      text: 'a big city',
      ranges: [{ startIndex: 2, endIndex: 5, style: 'bold' }],
    });

    await documentReplace({
      documentId: 'docA',
      old: 'a city',
      new: 'a **big** city',
    });

    expect(__.parseInlineMarkdown).toHaveBeenCalledWith('a **big** city');
    expect(getRequests()).toEqual([
      { deleteContentRange: { range: { startIndex: 10, endIndex: 16 } } },
      { insertText: { location: { index: 10 }, text: 'a big city' } },
      {
        updateTextStyle: {
          range: { startIndex: 12, endIndex: 15 },
          textStyle: { bold: true },
          fields: 'bold',
        },
      },
    ]);
  });

  it.each([
    {
      title: 'italic',
      range: { style: 'italic' },
      textStyle: { italic: true },
      fields: 'italic',
    },
    {
      title: 'code',
      range: { style: 'code' },
      textStyle: { weightedFontFamily: { fontFamily: 'Courier New' } },
      fields: 'weightedFontFamily',
    },
    {
      title: 'link',
      range: { style: 'link', url: 'https://example.com' },
      textStyle: { link: { url: 'https://example.com' } },
      fields: 'link',
    },
  ])('styles a $title range', async ({ range, textStyle, fields }) => {
    __.parseInlineMarkdown.mockReturnValue({
      text: 'word',
      ranges: [{ startIndex: 0, endIndex: 4, ...range }],
    });

    await documentReplace({ documentId: 'docA', old: 'x', new: 'word' });

    expect(getRequests()[2]).toEqual({
      updateTextStyle: {
        range: { startIndex: 10, endIndex: 14 },
        textStyle,
        fields,
      },
    });
  });

  it('reads old and new from files, which win over the inline values', async () => {
    await documentReplace({
      documentId: 'docA',
      old: 'a',
      oldFile: './old.txt',
      new: 'b',
      newFile: './new.md',
    });

    expect(__.read).toHaveBeenCalledWith('./old.txt');
    expect(__.read).toHaveBeenCalledWith('./new.md');
    expect(__.findPassage).toHaveBeenCalledWith(doc, 'content of ./old.txt');
    expect(__.parseInlineMarkdown).toHaveBeenCalledWith('content of ./new.md');
  });

  it.each([
    { title: 'is empty', options: { new: '' } },
    { title: 'is not given', options: {} },
  ])('sends no insertion when the new passage $title', async ({ options }) => {
    await documentReplace({ documentId: 'docA', old: 'Pariss', ...options });

    expect(getRequests()).toEqual([
      { deleteContentRange: { range: { startIndex: 10, endIndex: 16 } } },
    ]);
  });

  it.each([
    { code: 'GDOC_PASSAGE_MISSING' },
    { code: 'GDOC_PASSAGE_REPEATED' },
    { code: 'GDOC_PASSAGE_MULTIPLE_PARAGRAPHS' },
  ])('sends nothing when the passage fails with $code', async ({ code }) => {
    const passageError = new Error('passage error');
    passageError.code = code;
    __.findPassage.mockImplementation(() => {
      throw passageError;
    });

    let actual = null;
    try {
      await documentReplace({
        documentId: 'docA',
        old: 'Pariss',
        new: 'Paris',
      });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', code);
    // Only the read of the Document
    expect(__.callApi).toHaveBeenCalledTimes(1);
  });

  it('returns the Document, formatted', async () => {
    const actual = await documentReplace({
      documentId: 'docA',
      old: 'Pariss',
      new: 'Paris',
    });

    expect(__.formatDocument).toHaveBeenCalledWith({
      documentId: 'docA',
      title: 'Old Title',
    });
    expect(actual).toEqual({ id: 'formatted' });
  });

  it.each([
    {
      title: 'no Document is given',
      options: { old: 'Pariss', new: 'Paris' },
      expected: 'GDOC_DOCUMENT_ID_MISSING',
    },
    {
      title: 'no old passage is given',
      options: { documentId: 'docA', new: 'Paris' },
      expected: 'GDOC_PASSAGE_OLD_MISSING',
    },
  ])('throws $expected when $title', async ({ options, expected }) => {
    let actual = null;
    try {
      await documentReplace(options);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', expected);
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
