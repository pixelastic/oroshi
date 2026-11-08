import { readFile } from 'node:fs/promises';
import { dirname } from 'node:path';
import { _, pMap } from 'golgoth';
import { remove } from 'firost';
import { callApi } from './callApi.js';
import { prepareImage } from './prepareImage.js';

export let __;

/**
 * Upload the images of a post as blobs, and build its images embed
 * Every image is prepared before the first upload, so an image that is too large fails the post before any blob is sent. A heavy image is compressed on a temporary copy, removed at the end.
 * @param {object[]} images - Images of a parsed post, each with an `alt` and a `path`
 * @returns {Promise<object>} The `app.bsky.embed.images` embed, in the order of the images
 */
export async function uploadImages(images) {
  const prepared = [];
  try {
    await pMap(
      images,
      async ({ path }) => {
        prepared.push(await __.prepareImage(path));
      },
      { concurrency: 1 },
    );

    const embedImages = await pMap(
      prepared,
      async ({ filepath, mimeType }, index) => {
        const { blob } = await __.callApi('com.atproto.repo.uploadBlob', {
          method: 'POST',
          body: await __.readFile(filepath),
          headers: { 'Content-Type': mimeType },
        });
        return { alt: images[index].alt, image: blob };
      },
      { concurrency: 1 },
    );

    return { $type: 'app.bsky.embed.images', images: embedImages };
  } finally {
    const temporaries = _.filter(prepared, 'isTemporary');
    await pMap(temporaries, ({ filepath }) => __.remove(dirname(filepath)));
  }
}

__ = {
  callApi,
  prepareImage,
  readFile,
  remove,
};
