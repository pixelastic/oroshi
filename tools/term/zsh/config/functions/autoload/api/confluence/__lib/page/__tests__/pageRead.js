import { __, pageRead } from '../pageRead.js';

describe('pageRead', () => {
  const page = {
    id: '123456',
    title: 'Paris Meetup',
    spaceId: '9',
    _links: { webui: '/spaces/ENG/pages/123456/Paris+Meetup' },
    body: { storage: { value: '<p>Hello</p>' } },
  };

  beforeEach(() => {
    vi.spyOn(__, 'parsePageId').mockReturnValue('123456');
    vi.spyOn(__, 'getConfig').mockReturnValue({ domain: 'work.atlassian.net' });
    vi.spyOn(__, 'callApi').mockReturnValue(page);
    vi.spyOn(__, 'formatPage').mockImplementation((input) => input);
  });

  it('calls the pages endpoint with the parsed id', async () => {
    await pageRead({ pageId: 'https://work.atlassian.net/wiki/pages/123456' });

    expect(__.parsePageId).toHaveBeenCalledWith(
      'https://work.atlassian.net/wiki/pages/123456',
    );
    expect(__.callApi).toHaveBeenCalledWith('pages/123456', {
      query: { 'body-format': 'storage' },
    });
  });

  it('returns the formatted page with its url built from the domain', async () => {
    const actual = await pageRead({ pageId: '123456' });

    expect(__.formatPage).toHaveBeenCalledWith(page);
    expect(actual).toEqual({
      id: '123456',
      title: 'Paris Meetup',
      spaceId: '9',
      url: 'https://work.atlassian.net/wiki/spaces/ENG/pages/123456/Paris+Meetup',
      markdown: '<p>Hello</p>',
    });
  });
});
