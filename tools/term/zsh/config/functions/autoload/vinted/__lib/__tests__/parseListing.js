import path from 'node:path';
import { remove, tmpDirectory, write, writeJson } from 'firost';
import { parseListing } from '../parseListing.js';

describe('parseListing', () => {
  let testDirectory;
  const validListing = {
    photos: ['front.jpg', 'photos/back.jpg'],
    title: "Le Seigneur des Anneaux - La Communauté de l'Anneau",
    description: 'Poche, bon état.',
    category: ['Books & Media', 'Books', 'Fiction'],
    isbn: '978-2-266-28274-3',
    condition: 'Good',
    price: 6.5,
  };

  /**
   * Write a listing JSON file in the test directory
   * @param {object} listing - Content of the file
   * @returns {string} Path of the file
   */
  async function writeListing(listing) {
    const listingPath = path.join(testDirectory, 'listing.json');
    await writeJson(listing, listingPath);
    return listingPath;
  }

  /**
   * Parse a listing and return the error it throws
   * @param {string} listingPath - Path of the listing file
   * @returns {Error|null} The error, or null
   */
  async function parseError(listingPath) {
    let actual = null;
    try {
      await parseListing(listingPath);
    } catch (error) {
      actual = error;
    }
    return actual;
  }

  beforeEach(async () => {
    testDirectory = tmpDirectory('vinted/parseListing');
    await write('', path.join(testDirectory, 'front.jpg'));
    await write('', path.join(testDirectory, 'photos/back.jpg'));
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  describe('valid listing', () => {
    it('returns the listing with photo paths resolved from the JSON file', async () => {
      const listingPath = await writeListing(validListing);

      const actual = await parseListing(listingPath);

      expect(actual).toEqual({
        ...validListing,
        photos: [
          path.join(testDirectory, 'front.jpg'),
          path.join(testDirectory, 'photos/back.jpg'),
        ],
      });
    });
  });

  describe('isbn', () => {
    it.each([
      { input: undefined, expected: '0000000000000' },
      { input: '', expected: '0000000000000' },
      { input: '   ', expected: '0000000000000' },
      { input: '978-2-266-28274-3', expected: '978-2-266-28274-3' },
    ])('resolves the isbn $input to $expected', async ({ input, expected }) => {
      const listingPath = await writeListing({ ...validListing, isbn: input });

      const actual = await parseListing(listingPath);

      expect(actual).toHaveProperty('isbn', expected);
    });
  });

  describe('language', () => {
    it('accepts a listing without language', async () => {
      const listingPath = await writeListing(validListing);

      const actual = await parseListing(listingPath);

      expect(actual).not.toHaveProperty('language');
    });

    it('keeps the language of the listing', async () => {
      const listingPath = await writeListing({
        ...validListing,
        language: 'French',
      });

      const actual = await parseListing(listingPath);

      expect(actual).toHaveProperty('language', 'French');
    });

    it('names the language when it is not a text', async () => {
      const listingPath = await writeListing({
        ...validListing,
        language: 42,
      });

      const actual = await parseError(listingPath);

      expect(actual).toHaveProperty('code', 'VINTED_LISTING_INVALID');
      expect(actual).toHaveProperty(
        'message',
        `${listingPath}: field "language" must be a text`,
      );
    });
  });

  describe('invalid listing', () => {
    it.each([
      { input: 'photos' },
      { input: 'title' },
      { input: 'description' },
      { input: 'category' },
      { input: 'condition' },
      { input: 'price' },
    ])('names the missing field $input', async ({ input }) => {
      const { [input]: _removed, ...listing } = validListing;
      const listingPath = await writeListing(listing);

      const actual = await parseError(listingPath);

      expect(actual).toHaveProperty('code', 'VINTED_LISTING_INVALID');
      expect(actual).toHaveProperty(
        'message',
        `${listingPath}: field "${input}" is required`,
      );
    });

    it.each([
      { field: 'photos', value: 'front.jpg', expected: 'a list of file paths' },
      { field: 'photos', value: [], expected: 'a list of file paths' },
      { field: 'photos', value: [42], expected: 'a list of file paths' },
      { field: 'title', value: 42, expected: 'a text' },
      { field: 'description', value: ['text'], expected: 'a text' },
      { field: 'category', value: 'Books', expected: 'a list of labels' },
      { field: 'category', value: [], expected: 'a list of labels' },
      { field: 'isbn', value: 9782266282743, expected: 'a text' },
      {
        field: 'condition',
        value: 'Mint',
        expected:
          'one of New with tags, New without tags, Very good, Good, Satisfactory',
      },
      { field: 'price', value: '6.5', expected: 'a number of at least 1' },
      { field: 'price', value: 0.5, expected: 'a number of at least 1' },
    ])(
      'names the field $field of value $value',
      async ({ field, value, expected }) => {
        const listingPath = await writeListing({
          ...validListing,
          [field]: value,
        });

        const actual = await parseError(listingPath);

        expect(actual).toHaveProperty('code', 'VINTED_LISTING_INVALID');
        expect(actual).toHaveProperty(
          'message',
          `${listingPath}: field "${field}" must be ${expected}`,
        );
      },
    );

    it('names the photo file that does not exist', async () => {
      const listingPath = await writeListing({
        ...validListing,
        photos: ['front.jpg', 'missing.jpg'],
      });

      const actual = await parseError(listingPath);

      expect(actual).toHaveProperty('code', 'VINTED_LISTING_PHOTO_MISSING');
      expect(actual).toHaveProperty(
        'message',
        `Photo not found: ${path.join(testDirectory, 'missing.jpg')}`,
      );
    });

    it('throws when the file is not valid JSON', async () => {
      const listingPath = path.join(testDirectory, 'listing.json');
      await write('{ not json', listingPath);

      const actual = await parseError(listingPath);

      expect(actual).toHaveProperty('code', 'VINTED_LISTING_JSON_INVALID');
      expect(actual).toHaveProperty(
        'message',
        `${listingPath} is not a valid JSON file`,
      );
    });
  });
});
