import { __, pageReplace } from '../pageReplace.js';

describe('pageReplace', () => {
  const pageId = '11111111-1111-1111-1111-111111111111';
  const formatted = { id: pageId, url: 'u', properties: {}, markdown: '# A' };

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockImplementation((input) => input);
    vi.spyOn(__, 'read').mockImplementation((path) => `content of ${path}`);
    vi.spyOn(__, 'callApi').mockReturnValue({ id: pageId });
    vi.spyOn(__, 'pageRead').mockReturnValue(formatted);
  });

  /**
   * Build the body of the call to the markdown endpoint
   * @param {string} oldStr - Text to find
   * @param {string} newStr - Text to put instead
   * @returns {object} The body
   */
  function expectedBody(oldStr, newStr) {
    return {
      type: 'update_content',
      update_content: {
        content_updates: [{ old_str: oldStr, new_str: newStr }],
      },
    };
  }

  it('sends one search-and-replace operation with the old and new text', async () => {
    await pageReplace({ pageId, old: 'Pariss', new: 'Paris' });

    expect(__.callApi).toHaveBeenCalledWith(`pages/${pageId}/markdown`, {
      method: 'PATCH',
      body: expectedBody('Pariss', 'Paris'),
    });
  });

  it('reads old and new from files, which win over the inline values', async () => {
    await pageReplace({
      pageId,
      old: 'a',
      oldFile: './old.md',
      new: 'b',
      newFile: './new.md',
    });

    expect(__.read).toHaveBeenCalledWith('./old.md');
    expect(__.read).toHaveBeenCalledWith('./new.md');
    expect(__.callApi).toHaveBeenCalledWith(
      `pages/${pageId}/markdown`,
      expect.objectContaining({
        body: expectedBody('content of ./old.md', 'content of ./new.md'),
      }),
    );
  });

  it('surfaces the error when the old text is not found', async () => {
    const apiError = new Error('validation_error: old_str not found');
    apiError.code = 'NOTION_REQUEST_FAILED';
    __.callApi.mockImplementation(() => {
      throw apiError;
    });

    let actual = null;
    try {
      await pageReplace({ pageId, old: 'Missing', new: 'x' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'NOTION_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', apiError.message);
    expect(__.pageRead).not.toHaveBeenCalled();
  });

  it('accepts a URL as the Page id', async () => {
    __.parseId.mockReturnValue(pageId);
    const url = `https://www.notion.so/Meetup-${pageId.replaceAll('-', '')}`;

    await pageReplace({ pageId: url, old: 'a', new: 'b' });

    expect(__.parseId).toHaveBeenCalledWith(url);
    expect(__.callApi).toHaveBeenCalledWith(
      `pages/${pageId}/markdown`,
      expect.anything(),
    );
  });

  it('returns the updated Page, as read', async () => {
    const actual = await pageReplace({ pageId, old: 'a', new: 'b' });

    expect(__.pageRead).toHaveBeenCalledWith({ pageId });
    expect(actual).toEqual(formatted);
  });
});
