import { mkdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { _ } from 'golgoth';
import { google } from 'googleapis';
import { googleAuth } from '../../../__lib/googleAuth.js';

export let __;

/**
 * Fetch a Google Doc and convert it to Markdown with images
 * @param {string} urlOrId - Google Docs URL or document ID
 * @returns {object} { markdown, images, title, slug }
 */
export async function gdocs2md(urlOrId) {
  const docId = __.extractDocId(urlOrId);
  const auth = await __.getAuth();
  const doc = await __.fetchDoc(auth, docId);
  const title = doc.title || 'untitled';
  const slug = __.slugify(title);
  const { markdown, images } = __.convertToMarkdown(doc);
  return { markdown, images, title, slug };
}

__ = {
  /**
   * Extract document ID from a Google Docs URL or bare ID
   * @param {string} urlOrId - URL or document ID
   * @returns {string} Document ID
   */
  extractDocId(urlOrId) {
    const match = urlOrId.match(/\/document\/d\/([^/]+)/);
    if (match) {
      return match[1];
    }
    return urlOrId;
  },

  /**
   * Get authenticated Google OAuth2 client
   * @returns {object} OAuth2Client
   */
  getAuth() {
    return googleAuth();
  },

  /**
   * Fetch document JSON via Docs API
   * @param {object} auth - Authenticated OAuth2 client
   * @param {string} docId - Document ID
   * @returns {object} Google Docs document object
   */
  async fetchDoc(auth, docId) {
    const docs = google.docs({ version: 'v1', auth });
    const response = await docs.documents.get({ documentId: docId });
    return response.data;
  },

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
   * Convert a Google Docs document object to Markdown
   * @param {object} doc - Google Docs document object
   * @returns {object} { markdown, images }
   */
  convertToMarkdown(doc) {
    const elements = _.get(doc, 'body.content', []);
    const inlineObjects = doc.inlineObjects || {};
    const lists = doc.lists || {};
    const listCounters = {};
    const images = [];
    let previousType = 'none';

    const lines = _.map(elements, (element) => {
      // Tables
      if (element.table) {
        const needsBlankLine =
          previousType !== 'none' && previousType !== 'heading';
        previousType = 'table';
        const table = __.tableToMarkdown(element.table, inlineObjects, images);
        const before = needsBlankLine ? '\n' : '';
        return `${before}${table}\n`;
      }

      const para = element.paragraph;
      if (!para) {
        return null;
      }

      const text = __.elementsToMarkdown(
        para.elements || [],
        inlineObjects,
        images,
      );
      if (!text.trim()) {
        return null;
      }

      const styleType = _.get(
        para,
        'paragraphStyle.namedStyleType',
        'NORMAL_TEXT',
      );

      // Headings
      const headingMatch = styleType.match(/^HEADING_(\d)$/);
      if (headingMatch) {
        const level = parseInt(headingMatch[1], 10);
        const prefix = '#'.repeat(level);
        const isFirst = previousType === 'none';
        previousType = 'heading';
        const before = isFirst ? '' : '\n';
        return `${before}${prefix} ${text.trim()}\n\n`;
      }

      // List items
      if (para.bullet) {
        const { listId, nestingLevel = 0 } = para.bullet;
        const listDef = lists[listId];
        const nestingConfig = _.get(
          listDef,
          `listProperties.nestingLevels[${nestingLevel}]`,
          {},
        );
        const isOrdered = !!nestingConfig.glyphType;

        if (isOrdered) {
          listCounters[listId] = (listCounters[listId] || 0) + 1;
          previousType = 'list';
          return `${listCounters[listId]}. ${text.trim()}\n`;
        }

        previousType = 'list';
        return `- ${text.trim()}\n`;
      }

      // Blank line before paragraph if previous was list or paragraph
      const wrapped = __.wrapText(text.trim(), 80);
      const needsBlankLine =
        previousType === 'list' ||
        previousType === 'paragraph' ||
        previousType === 'table';
      previousType = 'paragraph';
      if (needsBlankLine) {
        return `\n${wrapped}\n`;
      }

      return `${wrapped}\n`;
    });

    return { markdown: _.compact(lines).join(''), images };
  },

  /**
   * Convert a Google Docs table to a Markdown table
   * @param {object} table - Google Docs table object
   * @param {object} inlineObjects - Document inline objects map
   * @param {object[]} images - Mutable image collection
   * @returns {string} Markdown table string
   */
  tableToMarkdown(table, inlineObjects, images) {
    const rows = _.map(table.tableRows || [], (row) => {
      return _.map(row.tableCells || [], (cell) => {
        const parts = _.map(cell.content || [], (el) => {
          if (!el.paragraph) {
            return '';
          }
          return __.elementsToMarkdown(
            el.paragraph.elements || [],
            inlineObjects,
            images,
          ).trim();
        });
        return _.compact(parts).join(' ');
      });
    });

    if (!rows.length) {
      return '';
    }

    const mdRows = _.map(rows, (cells) => {
      return `| ${cells.join(' | ')} |`;
    });
    const separator = `| ${_.map(rows[0], () => '---').join(' | ')} |`;
    mdRows.splice(1, 0, separator);

    return mdRows.join('\n');
  },

  /**
   * Wrap text at a given width, breaking at word boundaries
   * @param {string} text - Text to wrap
   * @param {number} width - Maximum line width
   * @returns {string} Wrapped text
   */
  wrapText(text, width) {
    const words = text.split(' ');
    const lines = [];
    let currentLine = '';

    for (const word of words) {
      if (!currentLine) {
        currentLine = word;
        continue;
      }
      if (currentLine.length + 1 + word.length > width) {
        lines.push(currentLine);
        currentLine = word;
      } else {
        currentLine += ` ${word}`;
      }
    }
    if (currentLine) {
      lines.push(currentLine);
    }

    return lines.join('\n');
  },

  /**
   * Convert paragraph elements (text runs) to inline Markdown
   * @param {object[]} elements - Array of paragraph elements
   * @param {object} inlineObjects - Document inline objects map
   * @param {object[]} images - Mutable image collection
   * @returns {string} Markdown text
   */
  elementsToMarkdown(elements, inlineObjects = {}, images = []) {
    return _.map(elements, (element) => {
      // Inline images
      if (element.inlineObjectElement) {
        const objectId = element.inlineObjectElement.inlineObjectId;
        const obj = inlineObjects[objectId];
        if (!obj) {
          return '';
        }
        const embedded = _.get(obj, 'inlineObjectProperties.embeddedObject');
        if (!embedded) {
          return '';
        }
        const contentUri = _.get(embedded, 'imageProperties.contentUri');
        if (!contentUri) {
          return '';
        }
        const index = images.length + 1;
        const filename = `image-${index}.png`;
        const alt = embedded.title || embedded.description || '';
        images.push({ contentUri, filename });
        return `![${alt}](${filename})`;
      }

      const run = element.textRun;
      if (!run) {
        return '';
      }

      let text = run.content.replace(/\n$/, '').replace(/\u00A0/g, ' ');
      const style = run.textStyle || {};

      if (style.bold) {
        text = `**${text}**`;
      }
      if (style.italic) {
        text = `*${text}*`;
      }
      if (style.link && style.link.url) {
        text = `[${text}](${style.link.url})`;
      }

      return text;
    }).join('');
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
   * @param {string} outputDir - Directory to write to
   * @param {string} markdown - Markdown content
   * @param {object[]} images - Array of { contentUri, filename }
   */
  async writeOutput(outputDir, markdown, images) {
    await mkdir(outputDir, { recursive: true });
    await writeFile(join(outputDir, 'index.md'), markdown);
    for (const img of images) {
      await __.downloadImage(img.contentUri, join(outputDir, img.filename));
    }
  },
};

// CLI entry
const currentFile = fileURLToPath(import.meta.url);
if (process.argv[1] === currentFile) {
  const input = process.argv[2];

  if (!input) {
    console.error('Usage: gdocs2md <url-or-doc-id>');
    process.exit(1);
  }

  const { markdown, images, slug } = await gdocs2md(input);
  const outputDir = join(process.cwd(), slug);
  await __.writeOutput(outputDir, markdown, images);
  console.log(outputDir);
}
