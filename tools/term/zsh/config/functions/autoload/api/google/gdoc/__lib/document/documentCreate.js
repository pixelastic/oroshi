import { basename, extname } from 'node:path';
import { getConfig } from '@oroshi/google/getConfig.js';
import { documentSetPageless } from './documentSetPageless.js';
import { formatDocument } from './formatDocument.js';
import { parseDirectoryId } from './parseDirectoryId.js';
import { readDocx } from './readDocx.js';
import { uploadDocx } from './uploadDocx.js';

export let __;

const DOCS_MIME_TYPE = 'application/vnd.google-apps.document';

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
  const content = await __.readDocx(filepath);

  const { docsFolderId } = await __.getConfig();
  const title = options.title || basename(filepath, extname(filepath));
  const parentId = parseDirectoryId(options.directory || docsFolderId);
  // Without a folder, the Document lands at the root of the Drive
  const metadata = {
    name: title,
    mimeType: DOCS_MIME_TYPE,
    ...(parentId && { parents: [parentId] }),
  };

  const response = await __.uploadDocx({
    path: 'files',
    method: 'POST',
    metadata,
    content,
  });

  await __.documentSetPageless(response.id);

  return __.formatDocument({ documentId: response.id, title: response.name });
}

__ = {
  documentSetPageless,
  formatDocument,
  getConfig,
  readDocx,
  uploadDocx,
};
