import path from 'node:path';
import { _ } from 'golgoth';
import { exists, remove, tmpDirectory, write } from 'firost';
import { __, organizePhotos } from '../organizePhotos.js';

describe('organizePhotos', () => {
  let testDirectory;

  /**
   * Create empty photos in the test directory
   * @param {string[]} names - File names to create
   */
  async function createPhotos(names) {
    await Promise.all(
      _.map(names, (name) => write('', path.join(testDirectory, name))),
    );
  }

  /**
   * Check that a path exists in the test directory
   * @param {string} relativePath - Path to check
   * @returns {Promise<boolean>} True if it exists
   */
  async function has(relativePath) {
    return await exists(path.join(testDirectory, relativePath));
  }

  beforeEach(() => {
    testDirectory = tmpDirectory('vinted/organizePhotos');
    vi.spyOn(__, 'run').mockReturnValue({ stdout: '', stderr: '' });
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  describe('folders', () => {
    it('creates one folder per group, with its photos', async () => {
      await createPhotos(['a.jpg', 'b.jpg', 'c.jpg', 'd.jpg', 'e.jpg']);
      const groups = [
        {
          series: 'Strange',
          number: '175',
          photos: ['a.jpg', 'b.jpg', 'c.jpg', 'd.jpg'],
        },
        { series: 'Dune', photos: ['e.jpg'] },
      ];

      await organizePhotos(testDirectory, groups);

      expect(await has('Strange - 175/01.jpg')).toBe(true);
      expect(await has('Strange - 175/04.jpg')).toBe(true);
      expect(await has('Dune/01.jpg')).toBe(true);
      expect(await has('a.jpg')).toBe(false);
      expect(await has('e.jpg')).toBe(false);
    });

    it('keeps the order of the photos of the group', async () => {
      await createPhotos(['a.jpg', 'b.png']);

      await organizePhotos(testDirectory, [
        { series: 'Dune', photos: ['b.png', 'a.jpg'] },
      ]);

      expect(await has('Dune/01.png')).toBe(true);
      expect(await has('Dune/02.jpg')).toBe(true);
    });

    it('returns the folders and their photos', async () => {
      await createPhotos(['a.jpg', 'b.jpg']);

      const actual = await organizePhotos(testDirectory, [
        { series: 'Dune', number: 2, photos: ['a.jpg', 'b.jpg'] },
      ]);

      expect(actual).toEqual([
        {
          folder: path.join(testDirectory, 'Dune - 2'),
          photos: ['01.jpg', '02.jpg'],
        },
      ]);
    });

    it('suffixes the folder of a second copy of an item', async () => {
      await createPhotos(['a.jpg', 'b.jpg']);

      await organizePhotos(testDirectory, [
        { series: 'Dune', number: '1', photos: ['a.jpg'] },
        { series: 'Dune', number: '1', photos: ['b.jpg'] },
      ]);

      expect(await has('Dune - 1/01.jpg')).toBe(true);
      expect(await has('Dune - 1 (2)/01.jpg')).toBe(true);
    });
  });

  describe('naming', () => {
    it.each([
      {
        title: 'series and number',
        group: { series: 'Strange', number: '175' },
        expected: 'Strange - 175',
      },
      {
        title: 'series alone',
        group: { series: 'Strange' },
        expected: 'Strange',
      },
      {
        title: 'a slash in the series',
        group: { series: 'AC/DC', number: 3 },
        expected: 'AC-DC - 3',
      },
    ])('names a folder from $title', async ({ group, expected }) => {
      await createPhotos(['a.jpg']);

      await organizePhotos(testDirectory, [{ ...group, photos: ['a.jpg'] }]);

      expect(await has(`${expected}/01.jpg`)).toBe(true);
    });
  });

  describe('unsure groups', () => {
    it('moves an unsure group into Misc', async () => {
      await createPhotos(['a.jpg', 'b.jpg']);

      await organizePhotos(testDirectory, [
        { series: 'Strange', number: '175', photos: ['a.jpg'], unsure: true },
        { photos: ['b.jpg'], unsure: true },
      ]);

      expect(await has('Misc/Strange - 175/01.jpg')).toBe(true);
      expect(await has('Misc/Unknown 2/01.jpg')).toBe(true);
      expect(await has('Strange - 175')).toBe(false);
    });
  });

  describe('rotations', () => {
    it.each([
      { direction: 'left', degrees: '-90' },
      { direction: 'right', degrees: '90' },
    ])('rotates a photo $direction', async ({ direction, degrees }) => {
      await createPhotos(['a.jpg', 'b.jpg']);

      await organizePhotos(testDirectory, [
        {
          series: 'Dune',
          photos: ['a.jpg', 'b.jpg'],
          rotations: { 'b.jpg': direction },
        },
      ]);

      const photo = path.join(testDirectory, 'Dune/02.jpg');
      expect(__.run).toHaveBeenCalledTimes(1);
      expect(__.run).toHaveBeenCalledWith([
        'magick',
        photo,
        '-auto-orient',
        '-rotate',
        degrees,
        photo,
      ]);
    });

    it('does not rotate when there is no rotation', async () => {
      await createPhotos(['a.jpg']);

      await organizePhotos(testDirectory, [
        { series: 'Dune', photos: ['a.jpg'] },
      ]);

      expect(__.run).not.toHaveBeenCalled();
    });

    it('throws on an unknown direction, before moving anything', async () => {
      await createPhotos(['a.jpg']);

      let actual = null;
      try {
        await organizePhotos(testDirectory, [
          {
            series: 'Dune',
            photos: ['a.jpg'],
            rotations: { 'a.jpg': 'upside-down' },
          },
        ]);
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'VINTED_PHOTO_BAD_ROTATION');
      expect(await has('a.jpg')).toBe(true);
    });
  });
});
