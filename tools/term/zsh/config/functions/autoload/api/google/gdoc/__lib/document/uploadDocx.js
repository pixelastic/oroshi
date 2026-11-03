import { randomUUID } from 'node:crypto';
import { callApi } from '../callApi.js';
import { multipartBody } from './multipartBody.js';

export let __;

const UPLOAD_URL = 'https://www.googleapis.com/upload/drive/v3';

/**
 * Upload a docx to the Drive, converted to a Google Doc
 * @param {object} options - Request and file
 * @param {string} options.path - Path of the Drive endpoint, files or files/<id>
 * @param {string} options.method - HTTP method, POST to create and PATCH to update
 * @param {object} options.metadata - Metadata of the file
 * @param {Buffer} options.content - Content of the docx
 * @returns {Promise<object>} The id and name of the Document
 */
export async function uploadDocx({ path, method, metadata, content }) {
  const boundary = `oroshi-${randomUUID()}`;
  return await __.callApi(path, {
    baseUrl: UPLOAD_URL,
    method,
    query: { uploadType: 'multipart', fields: 'id,name' },
    headers: { 'Content-Type': `multipart/related; boundary=${boundary}` },
    body: multipartBody({ boundary, metadata, content }),
  });
}

__ = {
  callApi,
};
