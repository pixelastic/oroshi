import { __, pageAppend } from '../pageAppend.js';

describe('pageAppend', () => {
  const pageId = '11111111-1111-1111-1111-111111111111';
  const formatted = { id: pageId, url: 'u', properties: {}, markdown: '# A' };

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockImplementation((input) => input);
    vi.spyOn(__, 'read').mockReturnValue('From file');
    vi.spyOn(__, 'callApi').mockReturnValue({ id: pageId });
    vi.spyOn(__, 'pageRead').mockReturnValue(formatted);
  });

  it('sends the content to insert at the end of the page', async () => {
    await pageAppend({ pageId, content: '## New section' });

    expect(__.callApi).toHaveBeenCalledWith(`pages/${pageId}/markdown`, {
      method: 'PATCH',
      body: {
        type: 'insert_content',
        insert_content: { content: '## New section' },
      },
    });
  });

  it('reads the content from the file when given', async () => {
    await pageAppend({
      pageId,
      content: 'Inline',
      contentFile: './section.md',
    });

    expect(__.read).toHaveBeenCalledWith('./section.md');
    expect(__.callApi).toHaveBeenCalledWith(
      `pages/${pageId}/markdown`,
      expect.objectContaining({
        body: {
          type: 'insert_content',
          insert_content: { content: 'From file' },
        },
      }),
    );
  });

  it('accepts a URL as the Page id', async () => {
    __.parseId.mockReturnValue(pageId);
    const url = `https://www.notion.so/Meetup-${pageId.replaceAll('-', '')}`;

    await pageAppend({ pageId: url, content: 'x' });

    expect(__.parseId).toHaveBeenCalledWith(url);
    expect(__.callApi).toHaveBeenCalledWith(
      `pages/${pageId}/markdown`,
      expect.anything(),
    );
  });

  it('returns the updated Page, as read', async () => {
    const actual = await pageAppend({ pageId, content: 'x' });

    expect(__.pageRead).toHaveBeenCalledWith({ pageId });
    expect(actual).toEqual(formatted);
  });
});
