import { createReadStream } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { mkdirp, remove, run } from 'firost';
import { google } from 'googleapis';
import { googleAuth } from '../../google/googleAuth.js';

export let __;

const TMP_DIR = '/tmp/oroshi/md2gdocs';

/**
 * Convert a Markdown file to a Google Doc via Pandoc DOCX
 * @param {string} filepath - Path to the Markdown file
 * @param {object} [options] - Options
 * @param {string} [options.title] - Custom title (default: filename without extension)
 * @returns {string} URL of the created Google Doc
 */
export async function md2gdocs(filepath, options = {}) {
  const title = options.title || __.titleFromPath(filepath);
  const outputPath = `${TMP_DIR}/${title}.docx`;

  await __.runPandoc(filepath, outputPath, path.dirname(filepath));

  const auth = await __.getAuth();
  const docId = await __.uploadDoc(auth, title, outputPath);
  await __.setPageless(auth, docId);
  const url = `https://docs.google.com/document/d/${docId}/edit`;

  await __.openBrowser(url);
  await __.cleanup();

  return url;
}

__ = {
  /**
   * Google Drive folder ID from environment
   * @returns {string} Folder ID
   */
  get FOLDER_ID() {
    return process.env.OROSHI_GOOGLE_DRIVE_DOCS_FOLDER_ID;
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
   * Run Pandoc to convert Markdown to DOCX
   * @param {string} filepath - Input Markdown path
   * @param {string} outputPath - Output DOCX path
   * @param {string} cwd - Working directory for resolving local images
   * @returns {Promise<void>}
   */
  async runPandoc(filepath, outputPath, cwd) {
    const scriptDir = path.dirname(fileURLToPath(import.meta.url));
    const referencePath = path.join(scriptDir, 'reference.docx');
    await mkdirp(TMP_DIR);
    const command = `pandoc -f markdown-auto_identifiers "${filepath}" -o "${outputPath}" --reference-doc="${referencePath}" --extract-media=${TMP_DIR}/`;
    await run(command, { shell: true, stdout: false, stderr: false, cwd });
  },

  /**
   * Upload a DOCX file as a Google Doc via Drive API
   * @param {object} auth - Authenticated OAuth2 client
   * @param {string} title - Document title
   * @param {string} docxPath - Path to the DOCX file
   * @returns {string} Created document ID
   */
  async uploadDoc(auth, title, docxPath) {
    const drive = google.drive({ version: 'v3', auth });
    const response = await drive.files.create({
      requestBody: {
        name: title,
        mimeType: 'application/vnd.google-apps.document',
        parents: [__.FOLDER_ID],
      },
      media: {
        mimeType:
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        body: createReadStream(docxPath),
      },
    });
    return response.data.id;
  },

  /**
   * Switch a Google Doc to pageless mode
   * @param {object} auth - Authenticated OAuth2 client
   * @param {string} docId - Document ID
   * @returns {Promise<void>}
   */
  async setPageless(auth, docId) {
    const docs = google.docs({ version: 'v1', auth });
    await docs.documents.batchUpdate({
      documentId: docId,
      requestBody: {
        requests: [
          {
            updateDocumentStyle: {
              documentStyle: {
                documentFormat: { documentMode: 'PAGELESS' },
              },
              fields: 'documentFormat',
            },
          },
        ],
      },
    });
  },

  /**
   * Open a URL in the browser
   * @param {string} url - URL to open
   * @returns {Promise<void>}
   */
  async openBrowser(url) {
    await run(`xdg-open "${url}"`, {
      shell: true,
      stdout: false,
      stderr: false,
      detached: true,
    });
  },

  /**
   * Clean up the temp directory
   * @returns {Promise<void>}
   */
  cleanup() {
    return remove(TMP_DIR);
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
