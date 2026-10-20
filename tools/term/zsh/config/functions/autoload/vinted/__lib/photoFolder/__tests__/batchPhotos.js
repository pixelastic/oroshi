import path from 'node:path';
import { _ } from 'golgoth';
import { remove, tmpDirectory, write } from 'firost';
import { BATCH_OVERLAP, __, batchPhotos } from '../batchPhotos.js';

describe('batchPhotos', () => {
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
   * Build photo names, like p01.jpg
   * @param {number} count - Number of names
   * @returns {string[]} Names
   */
  function photoNames(count) {
    return _.times(count, (index) => `p${_.padStart(index + 1, 2, '0')}.jpg`);
  }

  beforeEach(() => {
    testDirectory = tmpDirectory('vinted/batchPhotos');
    vi.spyOn(__, 'readCaptureDates').mockReturnValue({});
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  describe('batches', () => {
    it('splits 40 photos into overlapping batches of 16', async () => {
      const names = photoNames(40);
      await createPhotos(names);

      const actual = await batchPhotos(testDirectory);

      expect(_.map(actual, 'length')).toEqual([16, 16, 14]);
      expect(actual).toHaveProperty('0', _.slice(names, 0, 16));
      expect(actual).toHaveProperty('1', _.slice(names, 13, 29));
      expect(actual).toHaveProperty('2', _.slice(names, 26, 40));
    });

    it('overlaps each batch with the next one', async () => {
      await createPhotos(photoNames(40));

      const actual = await batchPhotos(testDirectory);

      expect(_.takeRight(actual[0], BATCH_OVERLAP)).toEqual(
        _.take(actual[1], BATCH_OVERLAP),
      );
    });

    it.each([
      { title: 'a short last batch', count: 17, expected: [16, 4] },
      { title: 'photos that fit in one batch', count: 16, expected: [16] },
      { title: 'an empty folder', count: 0, expected: [] },
    ])('leaves $title as is', async ({ count, expected }) => {
      await createPhotos(photoNames(count));

      const actual = await batchPhotos(testDirectory);

      expect(_.map(actual, 'length')).toEqual(expected);
    });

    it('ignores files that are not photos and subfolders', async () => {
      await createPhotos(['a.jpg', 'notes.txt', 'Misc/b.jpg']);

      const actual = await batchPhotos(testDirectory);

      expect(actual).toEqual([['a.jpg']]);
    });
  });

  describe('order', () => {
    it.each([
      {
        title: 'orders photos by capture date',
        files: ['a.jpg', 'b.jpg', 'c.jpg'],
        dates: {
          'a.jpg': '2026-10-01T10:00:03',
          'b.jpg': '2026-10-01T10:00:01',
          'c.jpg': '2026-10-01T10:00:02',
        },
        expected: ['b.jpg', 'c.jpg', 'a.jpg'],
      },
      {
        title: 'falls back to the file name without capture date',
        files: ['c.jpg', 'a.jpg', 'b.jpg', 'dated.jpg'],
        dates: { 'dated.jpg': '2026-10-01T10:00:00' },
        expected: ['dated.jpg', 'a.jpg', 'b.jpg', 'c.jpg'],
      },
    ])('$title', async ({ files, dates, expected }) => {
      await createPhotos(files);
      __.readCaptureDates.mockReturnValue(dates);

      const actual = await batchPhotos(testDirectory);

      expect(actual).toEqual([expected]);
    });
  });
});
