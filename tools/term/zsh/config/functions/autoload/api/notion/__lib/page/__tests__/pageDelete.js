import { __, pageDelete } from '../pageDelete.js';

describe('pageDelete', () => {
  const pageId = '11111111-1111-1111-1111-111111111111';

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockReturnValue(pageId);
    vi.spyOn(__, 'callApi').mockReturnValue({ id: pageId, in_trash: true });
  });

  it('puts the Page in the Trash', async () => {
    await pageDelete({ pageId });

    expect(__.callApi).toHaveBeenCalledWith(`pages/${pageId}`, {
      method: 'PATCH',
      body: { in_trash: true },
    });
  });

  it('returns the id of the Page', async () => {
    const actual = await pageDelete({ pageId });

    expect(actual).toEqual(pageId);
  });

  it('accepts a URL as the Page id', async () => {
    const url = `https://www.notion.so/Meetup-${pageId.replaceAll('-', '')}`;

    await pageDelete({ pageId: url });

    expect(__.parseId).toHaveBeenCalledWith(url);
  });
});
