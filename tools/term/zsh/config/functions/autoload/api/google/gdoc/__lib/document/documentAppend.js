import { _ } from 'golgoth';
import { firostError, remove, tmpDirectory, write } from 'firost';
import { callApi } from '../callApi.js';
import { buildAppendRequests } from './buildAppendRequests.js';
import { documentDelete } from './documentDelete.js';
import { formatDocument } from './formatDocument.js';
import { parseDocumentId } from './parseDocumentId.js';
import { readDocx } from './readDocx.js';
import { uploadDocx } from './uploadDocx.js';

export let __;

const DOCS_MIME_TYPE = 'application/vnd.google-apps.document';

/**
 * Add Markdown at the end of a Google Doc, keeping its content and comments.
 * The Markdown is imported as a temporary Document, which is copied at the end
 * of the target, then trashed
 * @param {object} options - Document and content
 * @param {string} options.documentId - Document URL or ID. Throws GDOC_DOCUMENT_ID_MISSING if empty
 * @param {string} [options.content] - Markdown to add. Throws GDOC_CONTENT_MISSING if neither content nor contentFile is given
 * @param {string} [options.contentFile] - Path to a Markdown file. Wins over content
 * @returns {Promise<object>} The updated Document, formatted
 */
export async function documentAppend(options) {
  // Without a documentId, the endpoint would contain undefined
  if (!options.documentId) {
    throw firostError(
      'GDOC_DOCUMENT_ID_MISSING',
      'Pass the Document URL or ID',
    );
  }
  if (!options.content && !options.contentFile) {
    throw firostError(
      'GDOC_CONTENT_MISSING',
      'Pass the Markdown to add, or --content-file',
    );
  }

  const { documentId } = parseDocumentId(options.documentId);
  const content = await __.contentToDocx({
    content: options.content,
    contentFile: options.contentFile,
  });

  // The Document is read before the import, so a wrong ID creates no
  // temporary Document
  const target = await __.callApi(`documents/${documentId}`);
  const endIndex = _.last(target.body.content).endIndex;

  const temporary = await __.uploadDocx({
    path: 'files',
    method: 'POST',
    metadata: { name: 'oroshi-gdoc-append', mimeType: DOCS_MIME_TYPE },
    content,
  });

  try {
    const converted = await __.callApi(`documents/${temporary.id}`);
    const requests = __.buildAppendRequests(converted, endIndex);
    await __.callApi(`documents/${documentId}:batchUpdate`, {
      method: 'POST',
      body: { requests },
    });
  } finally {
    // The temporary Document must not stay in the Drive, whatever happens
    await __.documentDelete({ documentId: temporary.id });
  }

  return __.formatDocument({ documentId, title: target.title });
}

__ = {
  /**
   * Convert the Markdown to add into a docx. An inline content goes through a
   * temporary file, because the conversion reads files
   * @param {object} options - Content to convert
   * @param {string} [options.content] - Inline Markdown
   * @param {string} [options.contentFile] - Path to a Markdown file. Wins over content
   * @returns {Promise<Buffer>} The content of the docx
   */
  async contentToDocx({ content, contentFile }) {
    if (contentFile) {
      return await __.readDocx(contentFile);
    }

    const workDirectory = __.tmpDirectory('documentAppend');
    const filepath = `${workDirectory}/content.md`;
    try {
      await __.write(content, filepath);
      return await __.readDocx(filepath);
    } finally {
      await __.remove(workDirectory);
    }
  },
  buildAppendRequests,
  callApi,
  documentDelete,
  formatDocument,
  readDocx,
  remove,
  tmpDirectory,
  uploadDocx,
  write,
};
