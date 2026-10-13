import { __, pageUpdate } from '../pageUpdate.js';

describe('pageUpdate', () => {
  const pageId = '11111111-1111-1111-1111-111111111111';
  const properties = { Name: { title: [{ text: { content: 'Paris' } }] } };
  const formatted = { id: pageId, url: 'u', properties: {}, markdown: '# A' };

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockImplementation((input) => input);
    vi.spyOn(__, 'getJsonFromOptions').mockReturnValue(properties);
    vi.spyOn(__, 'callApi').mockReturnValue({ id: pageId });
    vi.spyOn(__, 'pageRead').mockReturnValue(formatted);
  });

  it('sends the properties to the Page', async () => {
    await pageUpdate({ pageId, data: '{}' });

    expect(__.getJsonFromOptions).toHaveBeenCalledWith(
      { pageId, data: '{}' },
      'data',
      {},
    );
    expect(__.callApi).toHaveBeenCalledWith(`pages/${pageId}`, {
      method: 'PATCH',
      body: { properties },
    });
  });

  it('ignores an icon key without throwing', async () => {
    __.getJsonFromOptions.mockReturnValue({ ...properties, icon: '🎲' });

    await pageUpdate({ pageId, data: '{}' });

    expect(__.callApi).toHaveBeenCalledWith(`pages/${pageId}`, {
      method: 'PATCH',
      body: { properties },
    });
  });

  it('accepts a URL as the Page id', async () => {
    __.parseId.mockReturnValue(pageId);
    const url = `https://www.notion.so/Meetup-${pageId.replaceAll('-', '')}`;

    await pageUpdate({ pageId: url, data: '{}' });

    expect(__.parseId).toHaveBeenCalledWith(url);
    expect(__.callApi).toHaveBeenCalledWith(
      `pages/${pageId}`,
      expect.anything(),
    );
  });

  it('returns the updated Page, as read', async () => {
    const actual = await pageUpdate({ pageId, data: '{}' });

    expect(__.pageRead).toHaveBeenCalledWith({ pageId });
    expect(actual).toEqual(formatted);
  });
});
