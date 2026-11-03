import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { formatDocument } from './formatDocument.js';
import { parseDocumentId } from './parseDocumentId.js';

export let __;

const DRIVE_URL = 'https://www.googleapis.com/drive/v3';

/**
 * Put a Google Doc in the Drive trash. The Drive delete endpoint is never
 * called, so the Document can be restored from the trash
 * @param {object} options - Id of the Document
 * @param {string} options.documentId - Document URL or ID. Throws GDOC_DOCUMENT_ID_MISSING if empty
 * @returns {Promise<object>} The Document, formatted, with trashed: true
 */
export async function documentDelete(options) {
  // Without a documentId, the endpoint would contain undefined
  if (!options.documentId) {
    throw firostError(
      'GDOC_DOCUMENT_ID_MISSING',
      'Pass the Document URL or ID',
    );
  }

  const { documentId } = parseDocumentId(options.documentId);
  const response = await __.callApi(`files/${documentId}`, {
    baseUrl: DRIVE_URL,
    method: 'PATCH',
    query: { fields: 'id,name,trashed' },
    body: { trashed: true },
  });

  return {
    ...__.formatDocument({ documentId, title: response.name }),
    trashed: response.trashed,
  };
}

__ = {
  callApi,
  formatDocument,
};
