import path from 'node:path';
import { _ } from 'golgoth';
import { glob, readJson } from 'firost';

const MISC_FOLDER = 'Misc';

/**
 * Read every listing under a root, except the Misc folder
 * Misc listings are not ready to publish, so they never take part in tracking.
 * @param {string} root - Folder holding one folder per listing
 * @returns {Promise<object[]>} Each listing as { folder, listing }, sorted by path
 */
export async function readListingFolders(root) {
  const absoluteRoot = path.resolve(root);
  const files = await glob('**/listing.json', { cwd: absoluteRoot });
  const kept = _.chain(files)
    .map((file) => path.resolve(absoluteRoot, file))
    .reject((file) =>
      _.startsWith(
        path.relative(absoluteRoot, file),
        `${MISC_FOLDER}${path.sep}`,
      ),
    )
    .sortBy()
    .value();

  return await Promise.all(
    kept.map(async (file) => ({
      folder: path.dirname(file),
      listing: await readJson(file),
    })),
  );
}
