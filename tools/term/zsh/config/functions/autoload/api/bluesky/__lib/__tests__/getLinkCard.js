import { __, getLinkCard } from '../getLinkCard.js';

describe('getLinkCard', () => {
  const page = (html, { ok = true } = {}) => ({
    ok,
    status: ok ? 200 : 404,
    text: () => html,
  });

  it.each([
    {
      title: 'reads the og tags',
      html: `<html><head>
        <title>Page title</title>
        <meta property="og:title" content="OG title">
        <meta property="og:description" content="OG description">
        <meta property="og:image" content="https://a.io/cover.png">
      </head></html>`,
      expected: {
        uri: 'https://a.io/post',
        title: 'OG title',
        description: 'OG description',
        imageUrl: 'https://a.io/cover.png',
      },
    },
    {
      title: 'falls back to the page title, without description or image',
      html: '<html><head><title>Page title</title></head></html>',
      expected: {
        uri: 'https://a.io/post',
        title: 'Page title',
        description: '',
        imageUrl: null,
      },
    },
    {
      title: 'reads tags whose attributes are in any order and quoting',
      html: `<meta content='Reversed &amp; quoted' property='og:title'>
        <meta name="og:image" content="/cover.png">`,
      expected: {
        uri: 'https://a.io/post',
        title: 'Reversed & quoted',
        description: '',
        imageUrl: 'https://a.io/cover.png',
      },
    },
  ])('$title', async ({ html, expected }) => {
    vi.spyOn(__, 'fetch').mockReturnValue(page(html));

    const actual = await getLinkCard('https://a.io/post');

    expect(actual).toEqual(expected);
  });

  it.each([
    {
      title: 'the page answers with an error status',
      mock: () => page('', { ok: false }),
      expected: 'Cannot fetch https://a.io/post: 404',
    },
    {
      title: 'the page cannot be reached',
      mock: () => {
        throw new Error('getaddrinfo ENOTFOUND');
      },
      expected: 'Cannot fetch https://a.io/post: getaddrinfo ENOTFOUND',
    },
  ])(
    'throws BLUESKY_LINK_CARD_FAILED when $title',
    async ({ mock, expected }) => {
      vi.spyOn(__, 'fetch').mockImplementation(mock);

      let actual = null;
      try {
        await getLinkCard('https://a.io/post');
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'BLUESKY_LINK_CARD_FAILED');
      expect(actual).toHaveProperty('message', expected);
    },
  );
});
