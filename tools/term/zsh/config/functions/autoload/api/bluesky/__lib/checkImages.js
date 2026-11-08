import { dirname } from 'node:path';
import { _, pMap } from 'golgoth';
import { remove } from 'firost';
import { prepareImage } from './prepareImage.js';

export let __;

/**
 * Check that every image of every post can be uploaded, before any post is published
 * Each image is prepared as uploadImages will do it, and its temporary copy is removed at once.
 * @param {object[]} posts - Posts returned by resolveLinkCards, each with its `images`
 * @returns {Promise} Resolves when all images are fine. Throws BLUESKY_IMAGE_TOO_LARGE on the first image that stays over the limit
 */
export async function checkImages(posts) {
  const images = _.chain(posts).flatMap('images').compact().value();
  await pMap(
    images,
    async ({ path }) => {
      const { filepath, isTemporary } = await __.prepareImage(path);
      if (isTemporary) {
        await __.remove(dirname(filepath));
      }
    },
    { concurrency: 1 },
  );
}

__ = {
  prepareImage,
  remove,
};
