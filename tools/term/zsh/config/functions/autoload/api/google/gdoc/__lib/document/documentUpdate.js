import { firostError } from 'firost';
import { documentSetPageless } from './documentSetPageless.js';
import { formatDocument } from './formatDocument.js';
import { parseDocumentId } from './parseDocumentId.js';
import { readDocx } from './readDocx.js';
import { uploadDocx } from './uploadDocx.js';

export let __;

const DOCS_MIME_TYPE = 'application/vnd.google-apps.document';

/**
 * Replace the whole content of a Google Doc with a Markdown or docx file. The
 * Document keeps its ID and URL. Unresolved comments are lost, with no check
 * @param {object} options - Document and file
 * @param {string} options.documentId - Document URL or ID. Throws GDOC_DOCUMENT_ID_MISSING if empty
 * @param {string} options.filepath - Path to a .md or .docx file. Throws GDOC_FILE_MISSING if empty, GDOC_FILE_UNSUPPORTED for another extension
 * @param {string} [options.title] - New title of the Document, defaults to the current title
 * @returns {Promise<object>} The updated Document, formatted
 */
export async function documentUpdate(options) {
  // Without a documentId, the endpoint would contain undefined
  if (!options.documentId) {
    throw firostError(
      'GDOC_DOCUMENT_ID_MISSING',
      'Pass the Document URL or ID',
    );
  }
  const { documentId } = parseDocumentId(options.documentId);
  const content = await __.readDocx(options.filepath);

  // Without a name in the metadata, Drive keeps the current title
  const metadata = {
    mimeType: DOCS_MIME_TYPE,
    ...(options.title && { name: options.title }),
  };

  const response = await __.uploadDocx({
    path: `files/${documentId}`,
    method: 'PATCH',
    metadata,
    content,
  });

  // The upload resets the layout of the Document
  await __.documentSetPageless(documentId);

  return __.formatDocument({ documentId, title: response.name });
}

__ = {
  documentSetPageless,
  formatDocument,
  readDocx,
  uploadDocx,
};
