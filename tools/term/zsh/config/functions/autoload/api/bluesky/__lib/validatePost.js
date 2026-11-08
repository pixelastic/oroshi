import { basename, extname } from 'node:path';
import { _, pMap } from 'golgoth';
import { countGraphemes } from './countGraphemes.js';
import { fileSize } from './fileSize.js';
import {
  IMAGE_EXTENSIONS,
  MAX_IMAGES,
  MAX_IMAGE_BYTES,
} from './imageLimits.js';

export let __;

const MAX_GRAPHEMES = 300;
const MAX_BYTES = 3000;

/**
 * Find what is wrong with parsed posts, without any network call
 * Length counts the final text of a post, not its Markdown source. Images are only read from the disk, never compressed.
 * @param {object[]} posts - Posts returned by parsePostMarkdown
 * @returns {Promise<object[]>} Violations, each with a `code`, a `level`, a `message`
 * and the `line` of the source where the post, or the image, starts
 */
export async function validatePost(posts) {
  const violations = await pMap(posts, async (post) => {
    const textProblems = _.map(__.findProblems(post.text), (problem) => ({
      ...problem,
      line: post.line,
    }));
    const imageProblems = await __.findImageProblems(post.images);
    return [...textProblems, ...imageProblems];
  });

  return _.flatten(violations);
}

__ = {
  /**
   * Check the text of one post against the limits of Bluesky
   * @param {string} text - Final text of the post
   * @returns {object[]} Problems, each with a `code`, a `level` and a `message`
   */
  findProblems(text) {
    if (_.trim(text) === '') {
      return [
        { code: 'empty', level: 'error', message: 'The post has no text' },
      ];
    }

    const graphemes = countGraphemes(text);
    const bytes = Buffer.byteLength(text);
    const problems = [];
    if (graphemes > MAX_GRAPHEMES) {
      problems.push({
        code: 'too-long-graphemes',
        level: 'error',
        message: `The post has ${graphemes} graphemes, the limit is ${MAX_GRAPHEMES}`,
      });
    }
    if (bytes > MAX_BYTES) {
      problems.push({
        code: 'too-long-bytes',
        level: 'error',
        message: `The post has ${bytes} bytes, the limit is ${MAX_BYTES}`,
      });
    }
    return problems;
  },
  /**
   * Check the images of one post against the limits of Bluesky
   * @param {object[]} images - Images of the post, each with an `alt`, a `path` and a `line`
   * @returns {Promise<object[]>} Problems, each with a `code`, a `level`, a `message` and a `line`
   */
  async findImageProblems(images) {
    const problems = [];
    if (images.length > MAX_IMAGES) {
      problems.push({
        code: 'too-many-images',
        level: 'error',
        line: images[MAX_IMAGES].line,
        message: `The post has ${images.length} images, the limit is ${MAX_IMAGES}`,
      });
    }

    const imageProblems = await pMap(images, __.findProblemsOfImage);
    return [...problems, ..._.flatten(imageProblems)];
  },
  /**
   * Check one image: its alt text, its format, its presence and its weight
   * @param {object} image - Image of a parsed post
   * @param {string} image.alt - Alt text of the image
   * @param {string} image.path - Absolute path of the image
   * @param {number} image.line - Line of the image in the source
   * @returns {Promise<object[]>} Problems, each with a `code`, a `level`, a `message` and the `line` of the image
   */
  async findProblemsOfImage({ alt, path, line }) {
    const problems = await __.checkImage(alt, path);
    return _.map(problems, (problem) => ({ ...problem, line }));
  },
  /**
   * @param {string} alt - Alt text of the image
   * @param {string} path - Absolute path of the image
   * @returns {Promise<object[]>} Problems, each with a `code`, a `level` and a `message`
   */
  async checkImage(alt, path) {
    const name = basename(path);
    const problems = [];
    if (_.trim(alt) === '') {
      problems.push({
        code: 'missing-alt',
        level: 'error',
        message: `The image ${name} has no alt text`,
      });
    }

    const extension = _.trimStart(extname(path).toLowerCase(), '.');
    if (!_.includes(IMAGE_EXTENSIONS, extension)) {
      problems.push({
        code: 'image-unsupported-format',
        level: 'error',
        message: `The image ${name} is not a ${_.join(IMAGE_EXTENSIONS, ' or ')}`,
      });
      return problems;
    }

    const size = await __.fileSize(path);
    if (size === null) {
      problems.push({
        code: 'image-not-found',
        level: 'error',
        message: `The image ${name} does not exist`,
      });
    }
    if (size > MAX_IMAGE_BYTES) {
      problems.push({
        code: 'image-heavy',
        level: 'warning',
        message: `The image ${name} weighs ${size} bytes, over the limit of ${MAX_IMAGE_BYTES}: it will be compressed at publish time`,
      });
    }
    return problems;
  },
  fileSize,
};
