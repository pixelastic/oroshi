import { __, uploadImages } from '../uploadImages.js';

describe('uploadImages', () => {
  const blob = (name) => ({ $type: 'blob', ref: { $link: name } });

  beforeEach(() => {
    vi.spyOn(__, 'prepareImage').mockImplementation((path) => ({
      filepath: path.endsWith('big.png') ? '/tmp/work/big.png' : path,
      mimeType: 'image/png',
      isTemporary: path.endsWith('big.png'),
    }));
    vi.spyOn(__, 'readFile').mockImplementation((path) => `bytes of ${path}`);
    vi.spyOn(__, 'remove').mockReturnValue();
    vi.spyOn(__, 'callApi').mockImplementation((path, { body }) => ({
      blob: blob(body),
    }));
  });

  const images = [
    { alt: 'Small', path: '/drafts/small.png', line: 1 },
    { alt: 'Big', path: '/drafts/big.png', line: 2 },
  ];

  it('uploads each prepared file as a blob, with its mime type', async () => {
    await uploadImages(images);

    expect(__.callApi).toHaveBeenCalledWith('com.atproto.repo.uploadBlob', {
      method: 'POST',
      body: 'bytes of /drafts/small.png',
      headers: { 'Content-Type': 'image/png' },
    });
    expect(__.callApi).toHaveBeenCalledWith('com.atproto.repo.uploadBlob', {
      method: 'POST',
      body: 'bytes of /tmp/work/big.png',
      headers: { 'Content-Type': 'image/png' },
    });
  });

  it('returns an images embed with the alt text, in order', async () => {
    const actual = await uploadImages(images);

    expect(actual).toEqual({
      $type: 'app.bsky.embed.images',
      images: [
        { alt: 'Small', image: blob('bytes of /drafts/small.png') },
        { alt: 'Big', image: blob('bytes of /tmp/work/big.png') },
      ],
    });
  });

  it('uploads nothing when an image is too large', async () => {
    __.prepareImage.mockImplementation((path) => {
      if (path.endsWith('big.png')) {
        throw new Error('too large');
      }
      return { filepath: path, mimeType: 'image/png', isTemporary: false };
    });
    const reversed = [images[1], images[0]];

    let actual = null;
    try {
      await uploadImages(reversed);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'too large');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('removes the temporary copy, and only it', async () => {
    await uploadImages(images);

    expect(__.remove).toHaveBeenCalledTimes(1);
    expect(__.remove).toHaveBeenCalledWith('/tmp/work');
  });
});
