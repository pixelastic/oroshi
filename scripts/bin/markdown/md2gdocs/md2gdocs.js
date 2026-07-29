import path from 'node:path';
import { Readable } from 'node:stream';
import { fileURLToPath } from 'node:url';
import { _ } from 'golgoth';
import { read } from 'firost';
import { google } from 'googleapis';
import { googleAuth } from '../../google/googleAuth.js';

export let __;

/**
 * Convert a Markdown file to a Google Doc in Automation/Docs/
 * @param {string} filepath - Path to the Markdown file
 * @param {object} [options] - Options
 * @param {string} [options.title] - Custom title (default: filename without extension)
 * @returns {string} URL of the created Google Doc
 */
export async function md2gdocs(filepath, options = {}) {
  const content = await __.readFile(filepath);
  const title = options.title || __.titleFromPath(filepath);
  const html = __.markdownToHtml(content);
  const auth = await __.getAuth();
  const docId = await __.uploadDoc(auth, title, html);
  return `https://docs.google.com/document/d/${docId}/edit`;
}

__ = {
  FOLDER_ID: '1FqDVbHOxbLNsNjF_QP_FVBCkhDCmIadj',

  /**
   * Read a file from disk
   * @param {string} filepath - Path to the file
   * @returns {Promise<string>} File content
   */
  readFile(filepath) {
    return read(filepath);
  },

  /**
   * Extract title from filepath (filename without extension)
   * @param {string} filepath - Path to the file
   * @returns {string} Title
   */
  titleFromPath(filepath) {
    return path.basename(filepath, path.extname(filepath));
  },

  /**
   * Get authenticated Google OAuth2 client
   * @returns {object} OAuth2Client
   */
  getAuth() {
    return googleAuth();
  },

  /**
   * Convert Markdown to HTML
   * @param {string} markdown - Markdown content
   * @returns {string} HTML string
   */
  markdownToHtml(markdown) {
    const blocks = __.splitBlocks(markdown);
    return _.map(blocks, (block) => __.blockToHtml(block)).join('');
  },

  /**
   * Split markdown into logical blocks (headings, lists, paragraphs)
   * @param {string} markdown - Markdown content
   * @returns {string[]} Array of block strings
   */
  splitBlocks(markdown) {
    const lines = markdown.split('\n');
    const acc = _.reduce(
      lines,
      (state, line) => {
        if (line === '') {
          return __.flushCurrent(state);
        }

        // Headings are always their own block
        if (line.match(/^#{1,6}\s/)) {
          const flushed = __.flushCurrent(state);
          return { ...flushed, blocks: [...flushed.blocks, line] };
        }

        // List items group together
        if (line.match(/^- /)) {
          const base =
            state.current.length && !state.current[0].match(/^- /)
              ? __.flushCurrent(state)
              : state;
          return { ...base, current: [...base.current, line] };
        }

        // Paragraph text — close list if previous was a list
        const base =
          state.current.length && state.current[0].match(/^- /)
            ? __.flushCurrent(state)
            : state;
        return { ...base, current: [...base.current, line] };
      },
      { blocks: [], current: [] },
    );
    const final = __.flushCurrent(acc);
    return final.blocks;
  },

  /**
   * Flush current accumulator lines into a block
   * @param {object} state - Accumulator with blocks and current arrays
   * @returns {object} New state with current flushed
   */
  flushCurrent(state) {
    if (!state.current.length) {
      return state;
    }
    return {
      blocks: [...state.blocks, state.current.join('\n')],
      current: [],
    };
  },

  /**
   * Convert a single markdown block to HTML
   * @param {string} block - A markdown block (heading, paragraph, list)
   * @returns {string} HTML string
   */
  blockToHtml(block) {
    // Heading
    const headingMatch = block.match(/^(#{1,6})\s+(.+)$/);
    if (headingMatch) {
      const level = headingMatch[1].length;
      const text = __.inlineToHtml(headingMatch[2]);
      return `<h${level}>${text}</h${level}>`;
    }

    // Bullet list
    const lines = block.split('\n');
    if (_.every(lines, (line) => line.match(/^- /))) {
      const items = _.map(lines, (line) => {
        const text = __.inlineToHtml(line.replace(/^- /, ''));
        return `<li>${text}</li>`;
      });
      return `<ul>${items.join('')}</ul>`;
    }

    // Paragraph
    return `<p>${__.inlineToHtml(block)}</p>`;
  },

  /**
   * Convert inline Markdown formatting to HTML
   * @param {string} text - Text with inline markdown
   * @returns {string} HTML string
   */
  inlineToHtml(text) {
    let result = text;
    // Bold
    result = result.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
    // Italic
    result = result.replace(/\*(.+?)\*/g, '<em>$1</em>');
    // Links
    result = result.replace(/\[(.+?)\]\((.+?)\)/g, '<a href="$2">$1</a>');
    return result;
  },

  /**
   * Upload HTML as a Google Doc via Drive API
   * @param {object} auth - Authenticated OAuth2 client
   * @param {string} title - Document title
   * @param {string} html - HTML content
   * @returns {string} Created document ID
   */
  async uploadDoc(auth, title, html) {
    const drive = google.drive({ version: 'v3', auth });
    const response = await drive.files.create({
      requestBody: {
        name: title,
        mimeType: 'application/vnd.google-apps.document',
        parents: [__.FOLDER_ID],
      },
      media: {
        mimeType: 'text/html',
        body: Readable.from(html),
      },
    });
    return response.data.id;
  },
};

// CLI entry
const currentFile = fileURLToPath(import.meta.url);
if (process.argv[1] === currentFile) {
  const args = process.argv.slice(2);
  const titleIndex = args.indexOf('--title');
  let title;
  if (titleIndex !== -1) {
    title = args[titleIndex + 1];
    args.splice(titleIndex, 2);
  }
  const filepath = args[0];

  if (!filepath) {
    console.error('Usage: md2gdocs <file.md> [--title "Custom Title"]');
    process.exit(1);
  }

  const url = await md2gdocs(filepath, { title });
  console.log(url);
}
