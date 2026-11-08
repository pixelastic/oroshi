import { __, resolveLinkCards } from '../resolveLinkCards.js';

describe('resolveLinkCards', () => {
  const link = (uri) => ({
    index: { byteStart: 0, byteEnd: 1 },
    features: [{ $type: 'app.bsky.richtext.facet#link', uri }],
  });
  const card = {
    uri: 'https://a.io',
    title: 'A',
    description: '',
    imageUrl: null,
  };

  beforeEach(() => {
    vi.spyOn(__, 'getLinkCard').mockReturnValue(card);
  });

  it('attaches a card for the first link only', async () => {
    const posts = [
      {
        line: 1,
        images: [],
        facets: [link('https://a.io'), link('https://b.io')],
      },
    ];

    const actual = await resolveLinkCards(posts, {});

    expect(actual[0]).toMatchObject({ card, warnings: [] });
    expect(__.getLinkCard).toHaveBeenCalledTimes(1);
    expect(__.getLinkCard).toHaveBeenCalledWith('https://a.io');
  });

  it.each([
    {
      title: 'the post has images',
      posts: [
        { line: 1, images: [{ alt: 'a' }], facets: [link('https://a.io')] },
      ],
      options: {},
    },
    {
      title: 'the card is disabled',
      posts: [{ line: 1, images: [], facets: [link('https://a.io')] }],
      options: { noEmbed: true },
    },
    {
      title: 'the post has no link',
      posts: [{ line: 1, images: [], facets: [] }],
      options: {},
    },
    {
      title: 'the only link is an email address',
      posts: [{ line: 1, images: [], facets: [link('mailto:a@b.io')] }],
      options: {},
    },
  ])('attaches no card when $title', async ({ posts, options }) => {
    const actual = await resolveLinkCards(posts, options);

    expect(actual[0]).toMatchObject({ card: null, warnings: [] });
    expect(__.getLinkCard).not.toHaveBeenCalled();
  });

  it('keeps the link as a facet when the images win', async () => {
    const facets = [link('https://a.io')];
    const posts = [{ line: 1, images: [{ alt: 'a' }], facets }];

    const actual = await resolveLinkCards(posts, {});

    expect(actual).toHaveProperty('0.facets', facets);
  });

  it('warns and attaches no card when the page cannot be fetched', async () => {
    __.getLinkCard.mockImplementation(() => {
      throw new Error('Cannot fetch https://a.io: 404');
    });
    const posts = [{ line: 3, images: [], facets: [link('https://a.io')] }];

    const actual = await resolveLinkCards(posts, {});

    expect(actual[0]).toMatchObject({
      card: null,
      warnings: ['3 Cannot fetch https://a.io: 404'],
    });
  });
});
