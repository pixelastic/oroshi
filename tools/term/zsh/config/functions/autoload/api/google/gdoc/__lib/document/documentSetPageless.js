import { callApi } from '../callApi.js';

export let __;

/**
 * Switch a Google Doc to pageless mode
 * @param {string} documentId - Document ID
 * @returns {Promise<void>} Resolves when the Document is updated
 */
export async function documentSetPageless(documentId) {
  await __.callApi(`documents/${documentId}:batchUpdate`, {
    method: 'POST',
    body: {
      requests: [
        {
          updateDocumentStyle: {
            documentStyle: { documentFormat: { documentMode: 'PAGELESS' } },
            fields: 'documentFormat',
          },
        },
      ],
    },
  });
}

__ = {
  callApi,
};
