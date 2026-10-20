import path from 'node:path';
import { _ } from 'golgoth';
import { firostError, mkdirp, move, run } from 'firost';

export let __;

const MISC_FOLDER = 'Misc';
const DEGREES = { left: '-90', right: '90' };

/**
 * Organize photos into one folder per item, from the merged groups
 * Photos are renamed 01, 02... in the order of the group, and rotated when
 * the group asks for it. Unsure groups go into Misc/.
 * @param {string} folder - Folder holding the photos
 * @param {object[]} groups - Merged groups: series, number, photos, rotations, unsure
 * @returns {Promise<object[]>} Created folders, with their photo names
 */
export async function organizePhotos(folder, groups) {
  // Fail before moving anything
  __.assertRotations(groups);

  const plan = __.plan(folder, groups);
  await _.reduce(
    plan,
    async (previous, item) => {
      await previous;
      await __.organizeGroup(folder, item);
    },
    Promise.resolve(),
  );

  return _.map(plan, ({ destination, photos }) => ({
    folder: destination,
    photos: _.map(photos, 'name'),
  }));
}

__ = {
  /**
   * Check that every rotation is a known direction
   * @param {object[]} groups - Merged groups
   */
  assertRotations(groups) {
    const unknown = _.chain(groups)
      .flatMap((group) => _.values(group.rotations))
      .difference(_.keys(DEGREES))
      .first()
      .value();
    if (unknown) {
      throw firostError(
        'VINTED_PHOTO_BAD_ROTATION',
        `Unknown rotation "${unknown}", expected left or right`,
      );
    }
  },

  /**
   * Decide the destination folder and file names of every group
   * @param {string} folder - Folder holding the photos
   * @param {object[]} groups - Merged groups
   * @returns {object[]} destination, and photos with source, name and degrees
   */
  plan(folder, groups) {
    const used = [];
    return _.map(groups, (group, index) => {
      const parent = group.unsure ? path.join(folder, MISC_FOLDER) : folder;
      const destination = __.uniquePath(
        used,
        path.join(parent, __.folderName(group, index)),
      );
      const padding = Math.max(2, String(group.photos.length).length);

      return {
        destination,
        photos: _.map(group.photos, (photo, photoIndex) => ({
          source: path.join(folder, photo),
          name: `${_.padStart(photoIndex + 1, padding, '0')}${path.extname(photo).toLowerCase()}`,
          degrees: DEGREES[group.rotations?.[photo]],
        })),
      };
    });
  },

  /**
   * Name the folder of a group
   * @param {object} group - Merged group
   * @param {number} index - Position of the group in the list
   * @returns {string} Name like "Strange - 175", or "Unknown 3" without series
   */
  folderName(group, index) {
    const name = _.chain([group.series, group.number])
      .compact()
      .map((part) => _.chain(String(part)).trim().replaceAll('/', '-').value())
      .join(' - ')
      .value();
    return name || `Unknown ${index + 1}`;
  },

  /**
   * Suffix a path with a counter until nobody else uses it
   * @param {string[]} used - Paths already planned, updated in place
   * @param {string} candidate - Wanted path
   * @returns {string} Free path
   */
  uniquePath(used, candidate) {
    const free = _.chain(_.range(1, used.length + 2))
      .map((count) => (count === 1 ? candidate : `${candidate} (${count})`))
      .find((option) => !_.includes(used, option))
      .value();
    used.push(free);
    return free;
  },

  /**
   * Move the photos of a group into its folder, and rotate them
   * @param {string} folder - Folder holding the photos
   * @param {object} item - destination and photos of the group
   */
  async organizeGroup(folder, item) {
    await mkdirp(item.destination);
    await _.reduce(
      item.photos,
      async (previous, photo) => {
        await previous;
        const target = path.join(item.destination, photo.name);
        await move(photo.source, target);
        await __.rotate(target, photo.degrees);
      },
      Promise.resolve(),
    );
  },

  /**
   * Rotate a photo in place
   * @param {string} photo - Path of the photo
   * @param {string} [degrees] - Degrees to rotate by, nothing if missing
   */
  async rotate(photo, degrees) {
    if (!degrees) {
      return;
    }
    await __.run(['magick', photo, '-auto-orient', '-rotate', degrees, photo]);
  },

  run,
};
