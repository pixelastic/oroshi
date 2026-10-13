import { __, iconRead } from '../iconRead.js';

describe('iconRead', () => {
  const pageId = '3e07be57-b8fa-81bc-b066-c0275ed4b363';

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockReturnValue(pageId);
    vi.spyOn(__, 'callApi').mockReturnValue({ id: pageId });
    vi.spyOn(__, 'formatIcon').mockReturnValue('🎲');
  });

  it('returns the formatted Icon of the Page', async () => {
    const icon = { type: 'emoji', emoji: '🎲' };
    __.callApi.mockReturnValue({ id: pageId, icon });

    const actual = await iconRead({ pageId });

    expect(__.callApi).toHaveBeenCalledWith(`pages/${pageId}`);
    expect(__.formatIcon).toHaveBeenCalledWith(icon);
    expect(actual).toEqual('🎲');
  });

  it('returns an empty string when the Page has no Icon', async () => {
    __.formatIcon.mockReturnValue('');

    const actual = await iconRead({ pageId });

    expect(actual).toEqual('');
  });

  it('accepts a URL as the Page id', async () => {
    const url = `https://www.notion.so/workspace/Meetup-${pageId.replaceAll('-', '')}`;

    await iconRead({ pageId: url });

    expect(__.parseId).toHaveBeenCalledWith(url);
    expect(__.callApi).toHaveBeenCalledWith(`pages/${pageId}`);
  });
});
