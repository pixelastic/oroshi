import { __, prepareImage } from '../prepareImage.js';

describe('prepareImage', () => {
  // Size in bytes of each file, by path
  let sizes;
  let commands;

  beforeEach(() => {
    sizes = {};
    commands = [];
    vi.spyOn(__, 'tmpDirectory').mockReturnValue('/tmp/work');
    vi.spyOn(__, 'copy').mockReturnValue();
    vi.spyOn(__, 'fileSize').mockImplementation((path) => sizes[path]);
    vi.spyOn(__, 'run').mockImplementation((command) => {
      commands.push(command);
    });
  });

  it('uses the original file as is when it is under the limit', async () => {
    sizes['/drafts/cat.png'] = 999_999;

    const actual = await prepareImage('/drafts/cat.png');

    expect(actual).toEqual({
      filepath: '/drafts/cat.png',
      mimeType: 'image/png',
      isTemporary: false,
    });
    expect(__.copy).not.toHaveBeenCalled();
    expect(commands).toEqual([]);
  });

  it('compresses a copy of a heavy file, and keeps the original', async () => {
    sizes['/drafts/cat.png'] = 3_000_000;
    sizes['/tmp/work/cat.png'] = 800_000;

    const actual = await prepareImage('/drafts/cat.png');

    expect(__.copy).toHaveBeenCalledWith(
      '/drafts/cat.png',
      '/tmp/work/cat.png',
    );
    expect(commands).toEqual([
      ['zsh', '-ic', 'img-min "$@"', 'zsh', '/tmp/work/cat.png'],
    ]);
    expect(actual).toEqual({
      filepath: '/tmp/work/cat.png',
      mimeType: 'image/png',
      isTemporary: true,
    });
  });

  it('converts the copy to jpg when compression is not enough', async () => {
    sizes['/drafts/cat.png'] = 3_000_000;
    // Measured after the first img-min, then after the conversion
    const measures = {
      '/tmp/work/cat.png': 2_000_000,
      '/tmp/work/cat.jpg': 700_000,
    };
    __.fileSize.mockImplementation((path) => sizes[path] ?? measures[path]);

    const actual = await prepareImage('/drafts/cat.png');

    expect(commands).toEqual([
      ['zsh', '-ic', 'img-min "$@"', 'zsh', '/tmp/work/cat.png'],
      ['zsh', '-ic', 'img-convert -f "$@"', 'zsh', '/tmp/work/cat.png', 'jpg'],
      ['zsh', '-ic', 'img-min "$@"', 'zsh', '/tmp/work/cat.jpg'],
    ]);
    expect(actual).toEqual({
      filepath: '/tmp/work/cat.jpg',
      mimeType: 'image/jpeg',
      isTemporary: true,
    });
  });

  it('fails and names the file when the image stays too heavy', async () => {
    sizes['/drafts/cat.png'] = 3_000_000;
    sizes['/tmp/work/cat.png'] = 2_000_000;
    sizes['/tmp/work/cat.jpg'] = 1_500_000;
    vi.spyOn(__, 'remove').mockReturnValue();

    let actual = null;
    try {
      await prepareImage('/drafts/cat.png');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_IMAGE_TOO_LARGE');
    expect(actual).toHaveProperty(
      'message',
      '/drafts/cat.png is over 1000000 bytes, even compressed and converted to jpg',
    );
    expect(__.remove).toHaveBeenCalledWith('/tmp/work');
  });
});
