import path from 'node:path';
import { _ } from 'golgoth';
import { exists, glob, readJson } from 'firost';

const ITEM_ID_PATTERN = /\/items\/(\d+)/;

/**
 * Index the published listings under a root by Vinted item id
 * A listing is a JSON file in an annonces folder. Its url holds the item id,
 * so a listing without url is not published and is ignored.
 * @param {string} root - Folder holding the category folders
 * @returns {Promise<object>} { title, photoPath } by item id. photoPath is
 * null when the listing has no photo on disk
 */
export async function findListings(root) {
  const absoluteRoot = path.resolve(root);
  const files = await glob('**/annonces/*.json', { cwd: absoluteRoot });

  const entries = await Promise.all(
    _.map(files, async (file) => {
      const filepath = path.resolve(absoluteRoot, file);
      const listing = await readJson(filepath);
      const itemId = _.get(ITEM_ID_PATTERN.exec(listing.url), 1);
      if (!itemId) {
        return null;
      }

      const photo = _.first(listing.photos);
      const photoPath = photo
        ? path.resolve(path.dirname(filepath), photo)
        : null;
      return [
        itemId,
        {
          title: listing.title,
          photoPath: photoPath && (await exists(photoPath)) ? photoPath : null,
        },
      ];
    }),
  );

  return _.chain(entries).compact().fromPairs().value();
}
