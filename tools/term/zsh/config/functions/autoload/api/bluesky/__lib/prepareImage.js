import { basename, extname } from 'node:path';
import { copy, firostError, remove, run, tmpDirectory } from 'firost';
import { fileSize } from './fileSize.js';
import { MAX_IMAGE_BYTES } from './imageLimits.js';

export let __;

const MIME_TYPES = { '.jpg': 'image/jpeg', '.png': 'image/png' };

/**
 * Get an image small enough to upload, and leave the original untouched
 * An image under the limit is used as is. A heavier one is compressed on a temporary copy, then converted to jpg and compressed again if needed.
 * Run it only on images that exist, in a supported format.
 * @param {string} filepath - Absolute path of the image
 * @returns {Promise<object>} The `filepath` to upload, its `mimeType`, and `isTemporary` when the caller must remove the folder of `filepath` after the upload. Throws BLUESKY_IMAGE_TOO_LARGE when the image stays over the limit
 */
export async function prepareImage(filepath) {
  if ((await __.fileSize(filepath)) <= MAX_IMAGE_BYTES) {
    return __.describe(filepath, false);
  }

  const workDirectory = __.tmpDirectory('bluesky/image');
  const copyPath = `${workDirectory}/${basename(filepath)}`;
  await __.copy(filepath, copyPath);

  try {
    const prepared = await __.shrink(copyPath);
    if (!prepared) {
      throw firostError(
        'BLUESKY_IMAGE_TOO_LARGE',
        `${filepath} is over ${MAX_IMAGE_BYTES} bytes, even compressed and converted to jpg`,
      );
    }
    return __.describe(prepared, true);
  } catch (error) {
    await __.remove(workDirectory);
    throw error;
  }
}

__ = {
  /**
   * @param {string} filepath - Path of the image
   * @param {boolean} isTemporary - Whether the image is a temporary copy
   * @returns {object} The `filepath`, its `mimeType` and `isTemporary`
   */
  describe(filepath, isTemporary) {
    const mimeType = MIME_TYPES[extname(filepath).toLowerCase()];
    return { filepath, mimeType, isTemporary };
  },
  /**
   * Compress a copy in place, then convert it to jpg and compress it again if it is still too heavy
   * @param {string} copyPath - Path of the copy
   * @returns {Promise<string|null>} Path of the light enough image, or null when none is
   */
  async shrink(copyPath) {
    await __.imgMin(copyPath);
    if ((await __.fileSize(copyPath)) <= MAX_IMAGE_BYTES) {
      return copyPath;
    }

    // A jpg cannot get lighter by being converted to a jpg
    if (extname(copyPath).toLowerCase() === '.jpg') {
      return null;
    }

    const jpgPath = copyPath.replace(/\.[^.]+$/, '.jpg');
    await __.zsh('img-convert -f "$@"', copyPath, 'jpg');
    await __.imgMin(jpgPath);
    return (await __.fileSize(jpgPath)) <= MAX_IMAGE_BYTES ? jpgPath : null;
  },
  /**
   * @param {string} filepath - Path of the image to compress in place
   * @returns {Promise} Resolves when img-min is done
   */
  imgMin(filepath) {
    return __.zsh('img-min "$@"', filepath);
  },
  /**
   * Run a zsh function of the helpers, which needs an interactive zsh to exist
   * @param {string} script - Script to run, which reads its arguments as "$@"
   * @param {...string} args - Arguments of the script
   * @returns {Promise} Resolves when the script is done
   */
  zsh(script, ...args) {
    return __.run(['zsh', '-ic', script, 'zsh', ...args], { stdout: false });
  },
  copy,
  fileSize,
  remove,
  run,
  tmpDirectory,
};
