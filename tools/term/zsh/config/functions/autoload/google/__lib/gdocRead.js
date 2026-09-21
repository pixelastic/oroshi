import { fileURLToPath } from 'node:url';
import { _ } from 'golgoth';
import { google } from 'googleapis';
import { googleAuth } from './googleAuth.js';

export let __;

/**
 * Fetch a Google Doc and convert it to Markdown with image URLs
 * @param {string} urlOrId - Google Docs URL or document ID
 * @returns {object} { markdown, images, title }
 */
export async function gdocRead(urlOrId) {
  const docId = __.extractDocId(urlOrId);
  const auth = await __.googleAuth();
  const doc = await __.fetchDoc(auth, docId);
  const title = doc.title || 'untitled';
  const { markdown, images } = __.convertToMarkdown(doc);
  return { markdown, images, title };
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

    const markdown = _.chain(lines).compact().join('').value();
    return { markdown, images };
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
        return _.chain(parts).compact().join(' ').value();
      });
    });

    if (!rows.length) {
      return '';
    }

    const mdRows = _.map(rows, (cells) => {
      return `| ${cells.join(' | ')} |`;
    });
    const separator = `| ${_.chain(rows[0])
      .map(() => '---')
      .join(' | ')
      .value()} |`;
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
    const result = _.reduce(
      words,
      (acc, word) => {
        if (!acc.currentLine) {
          return { ...acc, currentLine: word };
        }
        if (acc.currentLine.length + 1 + word.length > width) {
          return {
            lines: [...acc.lines, acc.currentLine],
            currentLine: word,
          };
        }
        return { ...acc, currentLine: `${acc.currentLine} ${word}` };
      },
      { lines: [], currentLine: '' },
    );

    const lines = result.currentLine
      ? [...result.lines, result.currentLine]
      : result.lines;
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
    return _.chain(elements)
      .map((element) => {
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
          const alt = embedded.title || embedded.description || '';
          images.push({ contentUri });
          return `![${alt}](${contentUri})`;
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
      })
      .join('')
      .value();
  },

  googleAuth,
};

// CLI entry
const currentFile = fileURLToPath(import.meta.url);
if (process.argv[1] === currentFile) {
  const input = process.argv[2];

  if (!input) {
    console.error('Usage: gdoc-read <url-or-doc-id>');
    process.exit(1);
  }

  const { markdown } = await gdocRead(input);
  process.stdout.write(markdown);
}
