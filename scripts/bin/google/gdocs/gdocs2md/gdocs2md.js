import { fileURLToPath } from 'node:url';
import { _ } from 'golgoth';
import { google } from 'googleapis';
import { googleAuth } from '../../../google/googleAuth.js';

export let __;

/**
 * Fetch a Google Doc and convert it to Markdown
 * @param {string} urlOrId - Google Docs URL or document ID
 * @returns {string} Markdown content
 */
export async function gdocs2md(urlOrId) {
  const docId = __.extractDocId(urlOrId);
  const auth = await __.getAuth();
  const doc = await __.fetchDoc(auth, docId);
  return __.convertToMarkdown(doc);
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
   * Convert a Google Docs document object to Markdown
   * @param {object} doc - Google Docs document object
   * @returns {string} Markdown string
   */
  convertToMarkdown(doc) {
    const elements = _.get(doc, 'body.content', []);
    const lists = doc.lists || {};
    const listCounters = {};
    let previousType = 'none';

    const lines = _.map(elements, (element) => {
      const para = element.paragraph;
      if (!para) {
        return null;
      }

      const text = __.elementsToMarkdown(para.elements || []);
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
        previousType = 'heading';
        return `${prefix} ${text.trim()}\n`;
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
      const needsBlankLine =
        previousType === 'list' || previousType === 'paragraph';
      previousType = 'paragraph';
      if (needsBlankLine) {
        return `\n${text.trim()}\n`;
      }

      return `${text.trim()}\n`;
    });

    return _.compact(lines).join('');
  },

  /**
   * Convert paragraph elements (text runs) to inline Markdown
   * @param {object[]} elements - Array of paragraph elements
   * @returns {string} Markdown text
   */
  elementsToMarkdown(elements) {
    return _.map(elements, (element) => {
      const run = element.textRun;
      if (!run) {
        return '';
      }

      let text = run.content.replace(/\n$/, '');
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
};

// CLI entry
const currentFile = fileURLToPath(import.meta.url);
if (process.argv[1] === currentFile) {
  const input = process.argv[2];

  if (!input) {
    console.error('Usage: gdocs2md <url-or-doc-id>');
    process.exit(1);
  }

  const markdown = await gdocs2md(input);
  process.stdout.write(markdown);
}
