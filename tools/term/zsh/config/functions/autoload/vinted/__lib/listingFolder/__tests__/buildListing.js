import path from 'node:path';
import { readJson, remove, tmpDirectory, write } from 'firost';
import { parseListing } from '../../parseListing.js';
import { buildListing } from '../buildListing.js';

describe('buildListing', () => {
  let testDirectory;
  const identification = {
    series: 'Le Seigneur des Anneaux',
    number: 1,
    publisher: 'Pocket',
    isbn: '978-2-266-28274-3',
    price: 6,
  };

  /**
   * Build the listing and read the written file
   * @param {object} overrides - Identification data to override
   * @returns {Promise<object>} Content of listing.json
   */
  async function buildAndRead(overrides = {}) {
    await buildListing(testDirectory, { ...identification, ...overrides });
    return await readJson(path.join(testDirectory, 'listing.json'));
  }

  beforeEach(async () => {
    testDirectory = tmpDirectory('vinted/buildListing');
    await write('', path.join(testDirectory, 'front.jpg'));
    await write('', path.join(testDirectory, 'back.JPG'));
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  describe('fields', () => {
    it('writes every required field', async () => {
      const actual = await buildAndRead();

      expect(actual).toEqual({
        photos: ['back.JPG', 'front.jpg'],
        title: 'Le Seigneur des Anneaux n°1',
        description: 'Le Seigneur des Anneaux n°1. Éditions Pocket. Bon état.',
        category: ['Books & Media', 'Books', 'Fiction'],
        isbn: '978-2-266-28274-3',
        language: 'French',
        condition: 'Good',
        price: 6,
        status: 'draft',
        url: null,
        postedAt: null,
        soldAt: null,
      });
    });

    it('uses the given category', async () => {
      const category = ['Books & Media', 'Books', 'Non-fiction'];

      const actual = await buildAndRead({ category });

      expect(actual).toHaveProperty('category', category);
    });

    it('returns the path of the file', async () => {
      const actual = await buildListing(testDirectory, identification);

      expect(actual).toEqual(path.join(testDirectory, 'listing.json'));
    });
  });

  describe('photos', () => {
    it('lists the photos of subfolders relative to the folder', async () => {
      await write('', path.join(testDirectory, 'extra/side.png'));

      const actual = await buildAndRead();

      expect(actual).toHaveProperty('photos', [
        'back.JPG',
        'extra/side.png',
        'front.jpg',
      ]);
    });

    it('ignores files that are not photos', async () => {
      await write('{}', path.join(testDirectory, 'notes.txt'));

      const actual = await buildAndRead();

      expect(actual).toHaveProperty('photos', ['back.JPG', 'front.jpg']);
    });

    it('throws when the folder has no photo', async () => {
      await remove(path.join(testDirectory, 'front.jpg'));
      await remove(path.join(testDirectory, 'back.JPG'));

      let actual = null;
      try {
        await buildListing(testDirectory, identification);
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'VINTED_LISTING_NO_PHOTO');
    });
  });

  describe('isbn', () => {
    it.each([{ input: undefined }, { input: '' }, { input: '   ' }])(
      'falls back to the zero ISBN for $input',
      async ({ input }) => {
        const actual = await buildAndRead({ isbn: input });

        expect(actual).toHaveProperty('isbn', '0000000000000');
      },
    );
  });

  describe('title', () => {
    it('omits the number when there is none', async () => {
      const actual = await buildAndRead({ number: undefined });

      expect(actual).toHaveProperty('title', 'Le Seigneur des Anneaux');
    });
  });

  describe('tracking', () => {
    it('starts as a draft with no url nor date', async () => {
      const actual = await buildAndRead();

      expect(actual).toEqual(
        expect.objectContaining({
          status: 'draft',
          url: null,
          postedAt: null,
          soldAt: null,
        }),
      );
    });
  });

  describe('compatibility', () => {
    it('is accepted by parseListing', async () => {
      const listingPath = await buildListing(testDirectory, identification);

      const actual = await parseListing(listingPath);

      expect(actual).toHaveProperty('status', 'draft');
      expect(actual).toHaveProperty('photos', [
        path.join(testDirectory, 'back.JPG'),
        path.join(testDirectory, 'front.jpg'),
      ]);
    });
  });
});
