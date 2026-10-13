import { firostError } from 'firost';
import { __, pageRead } from '../pageRead.js';

describe('pageRead', () => {
  const pageId = '3e07be57-b8fa-81bc-b066-c0275ed4b363';
  const page = {
    id: pageId,
    url: 'https://www.notion.so/pageA',
    icon: { type: 'emoji', emoji: '🎲' },
    properties: { Name: { type: 'title', title: [] } },
  };
  const markdown = { id: pageId, markdown: '# Hello', truncated: false };

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockReturnValue(pageId);
    vi.spyOn(__, 'callApi').mockImplementation((path) =>
      path.endsWith('/markdown') ? markdown : page,
    );
    vi.spyOn(__, 'formatPage').mockReturnValue({
      id: pageId,
      url: 'https://www.notion.so/pageA',
      properties: { Name: { type: 'title', title: [] } },
    });
  });

  it('returns the id, url, properties and markdown of the Page', async () => {
    const actual = await pageRead({ pageId });

    expect(__.formatPage).toHaveBeenCalledWith(page);
    expect(actual).toEqual({
      id: pageId,
      url: 'https://www.notion.so/pageA',
      properties: { Name: { type: 'title', title: [] } },
      markdown: '# Hello',
    });
  });

  it('calls the API for the Page and for its markdown', async () => {
    await pageRead({ pageId });

    expect(__.callApi).toHaveBeenCalledWith(`pages/${pageId}`);
    expect(__.callApi).toHaveBeenCalledWith(`pages/${pageId}/markdown`);
  });

  it('accepts a URL as the Page id', async () => {
    const url = `https://www.notion.so/workspace/Meetup-${pageId.replaceAll('-', '')}`;

    await pageRead({ pageId: url });

    expect(__.parseId).toHaveBeenCalledWith(url);
    expect(__.callApi).toHaveBeenCalledWith(`pages/${pageId}`);
  });

  it('throws when the Page id is invalid', async () => {
    __.parseId.mockImplementation(() => {
      throw firostError('NOTION_ID_INVALID', 'No Notion id found');
    });

    let actual = null;
    try {
      await pageRead({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'NOTION_ID_INVALID');
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
