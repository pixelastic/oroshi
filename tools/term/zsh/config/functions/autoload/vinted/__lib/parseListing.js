import path from 'node:path';
import { _ } from 'golgoth';
import { exists, firostError, read } from 'firost';

export let __;

const CONDITIONS = [
  'New with tags',
  'New without tags',
  'Very good',
  'Good',
  'Satisfactory',
];
const PARCEL_SIZES = ['Small', 'Medium', 'Large'];
const MINIMUM_PRICE = 1;
const ZERO_ISBN = '0'.repeat(13);

/**
 * Read a listing JSON file, validate it, and resolve its photo paths
 * Runs before any browser opens, so every error is raised early.
 * @param {string} listingPath - Path of the listing JSON file
 * @returns {Promise<object>} The listing, with absolute photo paths
 */
export async function parseListing(listingPath) {
  const listing = __.withDefaultIsbn(await __.readListing(listingPath));
  __.validateFields(listing, listingPath);

  const directory = path.dirname(path.resolve(listingPath));
  const photos = listing.photos.map((photo) => path.resolve(directory, photo));
  await __.assertPhotosExist(photos);

  return { ...listing, photos };
}

__ = {
  /**
   * Check that a value is a non-empty string
   * @param {*} value - Value to check
   * @returns {boolean} True if valid
   */
  isText(value) {
    return typeof value === 'string' && value.trim() !== '';
  },

  /**
   * Check that a value is a non-empty list of non-empty strings
   * @param {*} value - Value to check
   * @returns {boolean} True if valid
   */
  isTextList(value) {
    return _.isArray(value) && !_.isEmpty(value) && value.every(__.isText);
  },

  /**
   * Describe each field, in the order errors are reported
   * @returns {object[]} Name, expected shape and validator of each field
   */
  fields() {
    return [
      {
        name: 'photos',
        expected: 'a list of file paths',
        isValid: __.isTextList,
      },
      { name: 'title', expected: 'a text', isValid: __.isText },
      { name: 'description', expected: 'a text', isValid: __.isText },
      {
        name: 'category',
        expected: 'a list of labels',
        isValid: __.isTextList,
      },
      { name: 'isbn', expected: 'a text', isValid: __.isText },
      {
        name: 'language',
        expected: 'a text',
        isValid: __.isText,
        isOptional: true,
      },
      {
        name: 'condition',
        expected: `one of ${CONDITIONS.join(', ')}`,
        isValid: (value) => CONDITIONS.includes(value),
      },
      {
        name: 'brand',
        expected: 'a text',
        isValid: __.isText,
        isOptional: true,
      },
      {
        name: 'platform',
        expected: 'a text',
        isValid: __.isText,
        isOptional: true,
      },
      {
        name: 'rating',
        expected: 'a text',
        isValid: __.isText,
        isOptional: true,
      },
      {
        name: 'colours',
        expected: 'a list of labels',
        isValid: __.isTextList,
        isOptional: true,
      },
      {
        name: 'parcelSize',
        expected: `one of ${PARCEL_SIZES.join(', ')}`,
        isValid: (value) => PARCEL_SIZES.includes(value),
        isOptional: true,
      },
      {
        name: 'price',
        expected: `a number of at least ${MINIMUM_PRICE}`,
        isValid: (value) => Number.isFinite(value) && value >= MINIMUM_PRICE,
      },
    ];
  },

  /**
   * Read and parse a JSON file
   * @param {string} listingPath - Path of the listing JSON file
   * @returns {Promise<object>} The parsed content
   */
  async readListing(listingPath) {
    const content = await read(listingPath);
    try {
      return JSON.parse(content);
    } catch {
      throw firostError(
        'VINTED_LISTING_JSON_INVALID',
        `${listingPath} is not a valid JSON file`,
      );
    }
  },

  /**
   * Replace a missing, empty or blank isbn with the zero ISBN
   * Vinted requires an ISBN, but accepts a string of zeros.
   * @param {object} listing - Parsed listing
   * @returns {object} The listing, with a usable isbn
   */
  withDefaultIsbn(listing) {
    const { isbn } = listing ?? {};
    const isBlank =
      isbn === undefined || (_.isString(isbn) && !__.isText(isbn));
    return isBlank ? { ...listing, isbn: ZERO_ISBN } : listing;
  },

  /**
   * Throw an error naming the first missing or invalid field
   * @param {object} listing - Parsed listing
   * @param {string} listingPath - Path of the listing, for the error message
   */
  validateFields(listing, listingPath) {
    __.fields().forEach(({ name, expected, isValid, isOptional }) => {
      const value = listing?.[name];
      if (value === undefined && isOptional) {
        return;
      }
      if (value === undefined) {
        throw firostError(
          'VINTED_LISTING_INVALID',
          `${listingPath}: field "${name}" is required`,
        );
      }
      if (!isValid(value)) {
        throw firostError(
          'VINTED_LISTING_INVALID',
          `${listingPath}: field "${name}" must be ${expected}`,
        );
      }
    });
  },

  /**
   * Throw an error naming the first photo that does not exist
   * @param {string[]} photos - Absolute photo paths
   */
  async assertPhotosExist(photos) {
    const found = await Promise.all(photos.map((photo) => exists(photo)));
    const missingIndex = found.indexOf(false);
    if (missingIndex === -1) {
      return;
    }
    throw firostError(
      'VINTED_LISTING_PHOTO_MISSING',
      `Photo not found: ${photos[missingIndex]}`,
    );
  },
};
