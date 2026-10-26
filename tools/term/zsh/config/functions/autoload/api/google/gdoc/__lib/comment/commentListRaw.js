import { _ } from 'golgoth';
import { firostError } from 'firost';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { callApi } from '../callApi.js';
import { parseDocumentId } from '../document/parseDocumentId.js';
import { formatComment } from './formatComment.js';

export let __;

const DRIVE_URL = 'https://www.googleapis.com/drive/v3';
const DEFAULT_LIMIT = 25;
const MAX_PAGE_SIZE = 100;
const FIELDS = [
  'nextPageToken',
  'comments(id,content,resolved,quotedFileContent,createdTime,author(displayName,me),replies(content,action,createdTime,author(displayName,me)))',
].join(',');

/**
 * List the unresolved Comments of a Document as raw lines, oldest first. A
 * line holds the Comment ID, its anchor, its text, its author, whether the
 * author is me, then its replies as "author: text"
 * @param {object} options - Options of the listing
 * @param {string} options.documentId - Document URL or ID. Throws GDOC_DOCUMENT_ID_MISSING if empty
 * @param {number} [options.limit] - Maximum number of Comments
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function commentListRaw(options) {
  const { limit = DEFAULT_LIMIT } = options;

  // Without a documentId, the endpoint would contain undefined
  if (!options.documentId) {
    throw firostError(
      'GDOC_DOCUMENT_ID_MISSING',
      'Pass the Document URL or ID',
    );
  }

  const { documentId } = parseDocumentId(options.documentId);
  const comments = await __.fetchComments(documentId, limit);

  return _.chain(comments)
    .sortBy('createdTime')
    .map(__.formatComment)
    .map(__.toLine)
    .join('\n')
    .value();
}

__ = {
  /**
   * Fetch the unresolved Comments of a Document, following the pages until it
   * has enough of them or the API has no more
   * @param {string} documentId - Document ID
   * @param {number} limit - Maximum number of Comments
   * @returns {Promise<object[]>} Unresolved Comments, as returned by the API
   */
  async fetchComments(documentId, limit) {
    const comments = [];
    let pageToken;
    do {
      const response = await __.callApi(`files/${documentId}/comments`, {
        baseUrl: DRIVE_URL,
        query: { fields: FIELDS, pageSize: MAX_PAGE_SIZE, pageToken },
      });
      comments.push(..._.reject(response.comments, { resolved: true }));
      pageToken = response.nextPageToken;
    } while (pageToken && comments.length < limit);

    return _.take(comments, limit);
  },

  /**
   * Turn one Comment into a raw line
   * @param {object} comment - Comment, as returned by formatComment
   * @returns {string} The Comment fields, separated by ▮
   */
  toLine(comment) {
    const replies = _.map(
      comment.replies,
      (reply) => `${reply.author.displayName}: ${reply.content}`,
    );
    return _.chain([
      comment.id,
      comment.anchor,
      comment.comment,
      comment.author.displayName,
      comment.author.isMe,
      replies,
    ])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },

  callApi,
  formatComment,
};
