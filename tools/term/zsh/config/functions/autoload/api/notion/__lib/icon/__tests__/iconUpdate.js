import { __, iconUpdate } from '../iconUpdate.js';

describe('iconUpdate', () => {
  const pageId = '3e07be57-b8fa-81bc-b066-c0275ed4b363';

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockReturnValue(pageId);
    vi.spyOn(__, 'callApi').mockReturnValue({ id: pageId, icon: null });
    vi.spyOn(__, 'formatIcon').mockReturnValue('formatted');
  });

  it.each([
    {
      title: 'an external image from a URL',
      input: 'https://example.com/a.png',
      expected: {
        type: 'external',
        external: { url: 'https://example.com/a.png' },
      },
    },
    {
      title: 'an emoji',
      input: '🎲',
      expected: { type: 'emoji', emoji: '🎲' },
    },
  ])('sets $title', async ({ input, expected }) => {
    await iconUpdate({ pageId, icon: input });

    expect(__.callApi).toHaveBeenCalledWith(`pages/${pageId}`, {
      method: 'PATCH',
      body: { icon: expected },
    });
  });

  it('returns the formatted Icon of the updated Page', async () => {
    const updated = { type: 'emoji', emoji: '🎲' };
    __.callApi.mockReturnValue({ id: pageId, icon: updated });

    const actual = await iconUpdate({ pageId, icon: '🎲' });

    expect(__.formatIcon).toHaveBeenCalledWith(updated);
    expect(actual).toEqual('formatted');
  });

  it('accepts a URL as the Page id', async () => {
    const url = `https://www.notion.so/workspace/Meetup-${pageId.replaceAll('-', '')}`;

    await iconUpdate({ pageId: url, icon: '🎲' });

    expect(__.parseId).toHaveBeenCalledWith(url);
    expect(__.callApi).toHaveBeenCalledWith(
      `pages/${pageId}`,
      expect.anything(),
    );
  });
});
