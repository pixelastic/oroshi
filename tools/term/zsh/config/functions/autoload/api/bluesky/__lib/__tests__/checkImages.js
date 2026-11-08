import { __, checkImages } from '../checkImages.js';

describe('checkImages', () => {
  beforeEach(() => {
    vi.spyOn(__, 'prepareImage').mockImplementation((path) => ({
      filepath: path.endsWith('big.png') ? '/tmp/work/big.png' : path,
      isTemporary: path.endsWith('big.png'),
    }));
    vi.spyOn(__, 'remove').mockReturnValue();
  });

  const posts = [
    { text: 'One', images: [{ alt: 'Small', path: '/drafts/small.png' }] },
    { text: 'Two' },
    { text: 'Three', images: [{ alt: 'Big', path: '/drafts/big.png' }] },
  ];

  it('prepares the images of every post', async () => {
    await checkImages(posts);

    expect(__.prepareImage).toHaveBeenCalledTimes(2);
    expect(__.prepareImage).toHaveBeenCalledWith('/drafts/small.png');
    expect(__.prepareImage).toHaveBeenCalledWith('/drafts/big.png');
  });

  it('removes the temporary copy, and only it', async () => {
    await checkImages(posts);

    expect(__.remove).toHaveBeenCalledTimes(1);
    expect(__.remove).toHaveBeenCalledWith('/tmp/work');
  });

  it('fails with the error of an image that is too large', async () => {
    __.prepareImage.mockImplementation(() => {
      throw new Error('too large');
    });

    let actual = null;
    try {
      await checkImages(posts);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'too large');
  });
});
