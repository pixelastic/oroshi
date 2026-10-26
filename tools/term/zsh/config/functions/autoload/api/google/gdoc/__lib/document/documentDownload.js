import { writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { _, pMap } from 'golgoth';
import { firostError, mkdirp, write } from 'firost';
import { documentRead } from './documentRead.js';

export let __;

/**
 * Download a Google Doc as a folder with its Markdown and its images
 * @param {object} options - Id of the Document
 * @param {string} options.documentId - Document URL or ID
 * @returns {Promise<string>} Path of the folder, created in the current directory
 */
export async function documentDownload(options) {
  const { markdown, images, title } = await __.documentRead({
    documentId: options.documentId,
  });

  // Images are renamed image-N.png, in the order of the Document
  const mapping = _.zipObject(
    images,
    _.map(images, (_url, index) => `image-${index + 1}.png`),
  );
  const outputDirectory = join(process.cwd(), __.slugify(title));

  await mkdirp(outputDirectory);
  await write(
    __.replaceImageUrls(markdown, mapping),
    join(outputDirectory, 'index.md'),
  );
  await pMap(_.toPairs(mapping), async ([url, filename]) => {
    await __.downloadImage(url, join(outputDirectory, filename));
  });

  return outputDirectory;
}

__ = {
  /**
   * Slugify a title for use as a directory name
   * @param {string} title - Document title
   * @returns {string} Slugified string
   */
  slugify(title) {
    return title
      .toLowerCase()
      .normalize('NFD')
      .replace(/[̀-ͯ]/g, '')
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '');
  },

  /**
   * Replace image URLs in markdown ![alt](url) patterns with local filenames
   * @param {string} markdown - Markdown content with source URLs
   * @param {object} mapping - Map of source URL to local filename
   * @returns {string} Markdown with local filenames
   */
  replaceImageUrls(markdown, mapping) {
    return markdown.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, (match, alt, url) => {
      if (mapping[url]) {
        return `![${alt}](${mapping[url]})`;
      }
      return match;
    });
  },

  /**
   * Download an image from a URL and save to disk
   * @param {string} url - Image URL
   * @param {string} filepath - Destination path
   */
  async downloadImage(url, filepath) {
    const response = await __.fetch(url);
    if (!response.ok) {
      throw firostError(
        'GDOC_IMAGE_DOWNLOAD_FAILED',
        `${response.status} ${url}`,
      );
    }
    const buffer = Buffer.from(await response.arrayBuffer());
    // firost write only accepts strings, and an image is binary
    await writeFile(filepath, buffer);
  },

  documentRead,
  fetch,
};
