import { __, uploadLinkCard } from '../uploadLinkCard.js';

describe('uploadLinkCard', () => {
  const blob = { $type: 'blob', ref: { $link: 'cover' } };
  const card = {
    uri: 'https://a.io/post',
    title: 'A',
    description: 'About A',
    imageUrl: 'https://a.io/cover.png',
  };

  const image = (bytes, type = 'image/png') => ({
    ok: true,
    headers: { get: () => type },
    arrayBuffer: () => new ArrayBuffer(bytes),
  });

  beforeEach(() => {
    vi.spyOn(__, 'fetch').mockReturnValue(image(10));
    vi.spyOn(__, 'callApi').mockReturnValue({ blob });
  });

  it('uploads the image and builds an external embed', async () => {
    const actual = await uploadLinkCard(card);

    expect(__.callApi).toHaveBeenCalledWith('com.atproto.repo.uploadBlob', {
      method: 'POST',
      body: expect.any(Buffer),
      headers: { 'Content-Type': 'image/png' },
    });
    expect(actual).toEqual({
      $type: 'app.bsky.embed.external',
      external: {
        uri: 'https://a.io/post',
        title: 'A',
        description: 'About A',
        thumb: blob,
      },
    });
  });

  it.each([
    {
      title: 'the card has no image',
      input: { ...card, imageUrl: null },
      mock: () => image(10),
    },
    {
      title: 'the image is too large',
      input: card,
      mock: () => image(1_000_001),
    },
    {
      title: 'the image cannot be fetched',
      input: card,
      mock: () => ({ ok: false, status: 404 }),
    },
    {
      title: 'the request fails',
      input: card,
      mock: () => {
        throw new Error('ENOTFOUND');
      },
    },
  ])('has no thumb when $title', async ({ input, mock }) => {
    __.fetch.mockImplementation(mock);

    const actual = await uploadLinkCard(input);

    expect(actual.external).not.toHaveProperty('thumb');
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
