import { parsePageId } from '../parsePageId.js';

describe('parsePageId', () => {
  it.each([
    { title: 'a bare id', input: '123456' },
    {
      title: 'a page URL',
      input: 'https://work.atlassian.net/wiki/spaces/ENG/pages/123456/My+Page',
    },
    {
      title: 'a page URL without title',
      input: 'https://work.atlassian.net/wiki/spaces/ENG/pages/123456',
    },
    {
      title: 'a page URL with a trailing slash',
      input: 'https://work.atlassian.net/wiki/spaces/ENG/pages/123456/',
    },
    {
      title: 'a page URL with a query',
      input:
        'https://work.atlassian.net/wiki/spaces/ENG/pages/123456?focusedCommentId=9',
    },
    {
      title: 'a page URL with a hash',
      input: 'https://work.atlassian.net/wiki/spaces/ENG/pages/123456#Section',
    },
  ])('returns the id of $title', ({ input }) => {
    const actual = parsePageId(input);

    expect(actual).toEqual('123456');
  });

  it.each([
    { title: 'an empty value', input: '' },
    { title: 'a missing value', input: undefined },
    {
      title: 'a URL without page id',
      input: 'https://work.atlassian.net/wiki',
    },
    { title: 'text', input: 'hello' },
  ])('throws on $title', ({ input }) => {
    let actual = null;
    try {
      parsePageId(input);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CONFLUENCE_ID_INVALID');
  });
});
