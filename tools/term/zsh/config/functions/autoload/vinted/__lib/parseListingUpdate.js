import path from 'node:path';
import { firostError } from 'firost';
import { __ as listing } from './parseListing.js';

export let __;

/**
 * Read a listing update JSON file and validate it
 * The file holds only the fields to change. Runs before any browser opens, so
 * every error is raised early.
 * @param {string} updatePath - Path of the update JSON file
 * @returns {Promise<object>} The fields to change, with absolute photo paths
 */
export async function parseListingUpdate(updatePath) {
  const update = await __.readUpdate(updatePath);
  __.validateFields(update, updatePath);

  if (!update.photos) {
    return update;
  }
  const directory = path.dirname(path.resolve(updatePath));
  const photos = update.photos.map((photo) => path.resolve(directory, photo));
  await __.assertPhotosExist(photos);
  return { ...update, photos };
}

__ = {
  /**
   * Throw an error naming the first invalid field among those present
   * @param {object} update - Parsed update
   * @param {string} updatePath - Path of the update, for the error message
   */
  validateFields(update, updatePath) {
    listing.fields().forEach(({ name, expected, isValid }) => {
      if (update?.[name] === undefined || isValid(update[name])) {
        return;
      }
      throw firostError(
        'VINTED_LISTING_INVALID',
        `${updatePath}: field "${name}" must be ${expected}`,
      );
    });
  },

  readUpdate: listing.readListing,
  assertPhotosExist: listing.assertPhotosExist,
};
