import { mkdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { _, pMap } from 'golgoth';
import { gdocRead } from './gdocRead.js';

export let __;

/**
 * Fetch a Google Doc and convert it to Markdown with local image filenames
 * @param {string} urlOrId - Google Docs URL or document ID
 * @returns {object} { markdown, images, title, slug }
 */
export async function gdoc2md(urlOrId) {
  const { markdown, images, title } = await __.gdocRead(urlOrId);
  const slug = __.slugify(title);

  const mapping = {};
  const localImages = _.map(images, (img, index) => {
    const filename = `image-${index + 1}.png`;
    mapping[img.contentUri] = filename;
    return { contentUri: img.contentUri, filename };
  });

  const localMarkdown = __.replaceImageUrls(markdown, mapping);
  return { markdown: localMarkdown, images: localImages, title, slug };
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
      .replace(/[\u0300-\u036f]/g, '')
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
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`Failed to download image: ${response.status}`);
    }
    const buffer = Buffer.from(await response.arrayBuffer());
    await writeFile(filepath, buffer);
  },

  /**
   * Write the full output directory: index.md + images
   * @param {string} outputDirectory - Directory to write to
   * @param {string} markdown - Markdown content
   * @param {object[]} images - Array of { contentUri, filename }
   */
  async writeOutput(outputDirectory, markdown, images) {
    await mkdir(outputDirectory, { recursive: true });
    await writeFile(join(outputDirectory, 'index.md'), markdown);
    await pMap(images, async (img) => {
      await __.downloadImage(
        img.contentUri,
        join(outputDirectory, img.filename),
      );
    });
  },

  gdocRead,
};

// CLI entry
const currentFile = fileURLToPath(import.meta.url);
if (process.argv[1] === currentFile) {
  const input = process.argv[2];

  if (!input) {
    console.error('Usage: gdoc2md <url-or-doc-id>');
    process.exit(1);
  }

  const { markdown, images, slug } = await gdoc2md(input);
  const outputDirectory = join(process.cwd(), slug);
  await __.writeOutput(outputDirectory, markdown, images);
  console.log(outputDirectory);
}
