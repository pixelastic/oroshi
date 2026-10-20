import path from 'node:path';
import { _ } from 'golgoth';
import { glob, run } from 'firost';
import { PHOTO_EXTENSIONS } from '../photoExtensions.js';

export let __;

export const BATCH_SIZE = 16;
// An item has at most 4 photos, so a batch overlap of 3 keeps it whole in one
export const BATCH_OVERLAP = 3;
const EXIF_DATE_FORMAT = '%Y-%m-%dT%H:%M:%S';

/**
 * Split the photos of a folder into overlapping batches, oldest photo first
 * Photos are ordered by capture date (EXIF), then by file name. Each batch
 * overlaps the next one, so no item is cut in every batch.
 * @param {string} folder - Folder holding the photos
 * @returns {Promise<string[][]>} Batches of file names, relative to the folder
 */
export async function batchPhotos(folder) {
  const files = await __.listPhotos(folder);
  const dates = await __.readCaptureDates(folder, files);

  const sorted = _.sortBy(files, [
    (file) => !dates[file],
    (file) => dates[file],
    _.identity,
  ]);

  return __.split(sorted);
}

__ = {
  /**
   * List the photos at the root of a folder
   * @param {string} folder - Folder holding the photos
   * @returns {Promise<string[]>} File names, relative to the folder
   */
  async listPhotos(folder) {
    const files = await glob('*', { cwd: folder, directories: false });
    return _.chain(files)
      .map((file) => path.relative(folder, file))
      .filter((file) =>
        PHOTO_EXTENSIONS.includes(path.extname(file).toLowerCase()),
      )
      .value();
  },

  /**
   * Read the capture date of photos, from their EXIF data
   * @param {string} folder - Folder holding the photos
   * @param {string[]} files - File names to read
   * @returns {Promise<object>} Capture date by file name, for photos that have one
   */
  async readCaptureDates(folder, files) {
    if (_.isEmpty(files)) {
      return {};
    }

    const { stdout } = await run(
      [
        'exiftool',
        '-json',
        '-DateTimeOriginal',
        '-dateformat',
        EXIF_DATE_FORMAT,
        ..._.map(files, (file) => path.join(folder, file)),
      ],
      { stdout: false, stderr: false },
    );

    return _.chain(JSON.parse(stdout))
      .filter('DateTimeOriginal')
      .keyBy((entry) => path.relative(folder, entry.SourceFile))
      .mapValues('DateTimeOriginal')
      .value();
  },

  /**
   * Split files into batches that overlap the next one
   * @param {string[]} files - Sorted file names
   * @returns {string[][]} Batches
   */
  split(files) {
    if (_.isEmpty(files)) {
      return [];
    }

    const step = BATCH_SIZE - BATCH_OVERLAP;
    // The last batch is the first one that reaches the last photo
    const count = Math.max(1, Math.ceil((files.length - BATCH_OVERLAP) / step));
    return _.times(count, (index) =>
      _.slice(files, index * step, index * step + BATCH_SIZE),
    );
  },

  run,
};
