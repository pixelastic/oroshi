import { randomUUID } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import { basename, dirname, extname, join, resolve } from 'node:path';
import { firostError, mkdirp, remove, run, tmpDirectory } from 'firost';
import { getConfig } from '@oroshi/google/getConfig.js';
import { callApi } from '../callApi.js';
import { documentSetPageless } from './documentSetPageless.js';
import { formatDocument } from './formatDocument.js';
import { parseDirectoryId } from './parseDirectoryId.js';

export let __;

const UPLOAD_URL = 'https://www.googleapis.com/upload/drive/v3';
const DOCS_MIME_TYPE = 'application/vnd.google-apps.document';
const DOCX_MIME_TYPE =
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

/**
 * Create a Google Doc from a Markdown or docx file
 * @param {object} options - File and destination of the Document
 * @param {string} options.filepath - Path to a .md or .docx file. Throws GDOC_FILE_MISSING if empty, GDOC_FILE_UNSUPPORTED for another extension
 * @param {string} [options.title] - Title of the Document, defaults to the file name without extension
 * @param {string} [options.directory] - Drive folder URL or ID, defaults to OROSHI_GOOGLE_DRIVE_DOCS_FOLDER_ID
 * @returns {Promise<object>} The created Document, formatted
 */
export async function documentCreate(options) {
  const { filepath } = options;
  if (!filepath) {
    throw firostError(
      'GDOC_FILE_MISSING',
      'Pass the path of a .md or .docx file',
    );
  }

  // Only a Markdown file is converted, a docx is uploaded as is
  const extension = extname(filepath);
  if (!['.md', '.docx'].includes(extension)) {
    throw firostError(
      'GDOC_FILE_UNSUPPORTED',
      `${filepath} must be a .md or .docx file`,
    );
  }
  const { docsFolderId, referenceDoc } = await __.getConfig();
  const docx =
    extension === '.md'
      ? await __.markdownToDocx(filepath, referenceDoc)
      : await __.readFile(filepath);

  const title = options.title || basename(filepath, extension);
  const parentId = parseDirectoryId(options.directory || docsFolderId);
  // Without a folder, the Document lands at the root of the Drive
  const metadata = {
    name: title,
    mimeType: DOCS_MIME_TYPE,
    ...(parentId && { parents: [parentId] }),
  };

  const boundary = `oroshi-${randomUUID()}`;
  const response = await __.callApi('files', {
    baseUrl: UPLOAD_URL,
    method: 'POST',
    query: { uploadType: 'multipart', fields: 'id,name' },
    headers: { 'Content-Type': `multipart/related; boundary=${boundary}` },
    body: __.multipartBody({ boundary, metadata, content: docx }),
  });

  await __.documentSetPageless(response.id);

  return __.formatDocument({ documentId: response.id, title: response.name });
}

__ = {
  /**
   * Convert a Markdown file to docx with pandoc
   * @param {string} filepath - Path to the Markdown file
   * @param {string} referenceDoc - Path to the pandoc reference document
   * @returns {Promise<Buffer>} Content of the docx
   */
  async markdownToDocx(filepath, referenceDoc) {
    const workDirectory = tmpDirectory('documentCreate');
    const docxPath = join(workDirectory, 'output.docx');
    // Pandoc runs from the folder of the file, so the path must be absolute
    const absolutePath = resolve(filepath);

    try {
      await __.mkdirp(workDirectory);
      await __.run(
        [
          'pandoc',
          '-f',
          'markdown-auto_identifiers',
          absolutePath,
          '-o',
          docxPath,
          `--reference-doc=${referenceDoc}`,
          `--extract-media=${workDirectory}/`,
        ],
        { cwd: dirname(absolutePath), stdout: false, stderr: false },
      );
      return await __.readFile(docxPath);
    } finally {
      await __.remove(workDirectory);
    }
  },

  /**
   * Build the multipart/related body of a Drive upload: the metadata as JSON,
   * then the docx
   * @param {object} input - Parts of the body
   * @param {string} input.boundary - Boundary that separates the parts
   * @param {object} input.metadata - Metadata of the file
   * @param {Buffer} input.content - Content of the docx
   * @returns {Blob} The body of the request
   */
  multipartBody({ boundary, metadata, content }) {
    return new Blob([
      `--${boundary}\r\n`,
      'Content-Type: application/json; charset=UTF-8\r\n\r\n',
      JSON.stringify(metadata),
      `\r\n--${boundary}\r\n`,
      `Content-Type: ${DOCX_MIME_TYPE}\r\n\r\n`,
      content,
      `\r\n--${boundary}--`,
    ]);
  },

  callApi,
  documentSetPageless,
  formatDocument,
  getConfig,
  mkdirp,
  readFile,
  remove,
  run,
};
