import path from 'node:path';
import { remove, tmpDirectory, write, writeJson } from 'firost';
import { parseListingUpdate } from '../parseListingUpdate.js';

describe('parseListingUpdate', () => {
  let testDirectory;

  /**
   * Write an update JSON file in the test directory
   * @param {object} update - Content of the file
   * @returns {string} Path of the file
   */
  async function writeUpdate(update) {
    const updatePath = path.join(testDirectory, 'update.json');
    await writeJson(update, updatePath);
    return updatePath;
  }

  beforeEach(async () => {
    testDirectory = tmpDirectory('vinted/parseListingUpdate');
    await write('', path.join(testDirectory, 'front.jpg'));
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  describe('partial update', () => {
    it('returns only the fields present in the file', async () => {
      const updatePath = await writeUpdate({ price: 8, condition: 'Good' });

      const actual = await parseListingUpdate(updatePath);

      expect(actual).toEqual({ price: 8, condition: 'Good' });
    });
  });

  describe('invalid field', () => {
    it.each([
      { name: 'price', value: 0, expected: 'a number of at least 1' },
      { name: 'title', value: '  ', expected: 'a text' },
      {
        name: 'condition',
        value: 'Broken',
        expected:
          'one of New with tags, New without tags, Very good, Good, Satisfactory',
      },
    ])('throws when $name is $value', async ({ name, value, expected }) => {
      const updatePath = await writeUpdate({ [name]: value });

      let actual = null;
      try {
        await parseListingUpdate(updatePath);
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'VINTED_LISTING_INVALID');
      expect(actual).toHaveProperty(
        'message',
        `${updatePath}: field "${name}" must be ${expected}`,
      );
    });
  });

  describe('photos', () => {
    it('resolves photo paths from the JSON file', async () => {
      const updatePath = await writeUpdate({ photos: ['front.jpg'] });

      const actual = await parseListingUpdate(updatePath);

      expect(actual).toEqual({
        photos: [path.join(testDirectory, 'front.jpg')],
      });
    });

    it('throws on a photo that does not exist', async () => {
      const updatePath = await writeUpdate({ photos: ['missing.jpg'] });

      let actual = null;
      try {
        await parseListingUpdate(updatePath);
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'VINTED_LISTING_PHOTO_MISSING');
      expect(actual).toHaveProperty(
        'message',
        `Photo not found: ${path.join(testDirectory, 'missing.jpg')}`,
      );
    });
  });
});
