const DOCX_MIME_TYPE =
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

/**
 * Build the multipart/related body of a Drive upload: the metadata as JSON,
 * then the docx
 * @param {object} input - Parts of the body
 * @param {string} input.boundary - Boundary that separates the parts
 * @param {object} input.metadata - Metadata of the file
 * @param {Buffer} input.content - Content of the docx
 * @returns {Blob} The body of the request
 */
export function multipartBody({ boundary, metadata, content }) {
  return new Blob([
    `--${boundary}\r\n`,
    'Content-Type: application/json; charset=UTF-8\r\n\r\n',
    JSON.stringify(metadata),
    `\r\n--${boundary}\r\n`,
    `Content-Type: ${DOCX_MIME_TYPE}\r\n\r\n`,
    content,
    `\r\n--${boundary}--`,
  ]);
}
