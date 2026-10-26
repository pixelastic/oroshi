import { _ } from 'golgoth';

export let __;

/**
 * Format one Comment, to give every command the same output
 * @param {object} response - The Comment, as returned by the Drive API
 * @returns {object} The Comment as { id, anchor, comment, author, replies }
 */
export function formatComment(response) {
  return {
    id: response.id,
    anchor: _.get(response, 'quotedFileContent.value', ''),
    comment: response.content,
    author: __.formatAuthor(response),
    replies: _.chain(response.replies)
      .sortBy('createdTime')
      .map((reply) => ({
        content: reply.content,
        author: __.formatAuthor(reply),
      }))
      .value(),
  };
}

__ = {
  /**
   * Format the author of a Comment or a reply
   * @param {object} entry - Comment or reply, as returned by the Drive API
   * @returns {object} The author as { displayName, isMe }
   */
  formatAuthor(entry) {
    return {
      displayName: _.get(entry, 'author.displayName', ''),
      isMe: _.get(entry, 'author.me', false),
    };
  },
};
