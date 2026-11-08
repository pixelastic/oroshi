import { _ } from 'golgoth';

/**
 * Format a Post, to give every command the same output
 * @param {object} post - The Post. Only `uri` is required: a record just created has no more
 * @param {string} post.uri - AT URI of the Post
 * @param {string} [post.handle] - Handle of its author
 * @param {string} [post.createdAt] - Date of creation, as an ISO string
 * @param {string} [post.text] - Text of the Post
 * @returns {{uri: string, url: string, handle?: string, createdAt?: string, text?: string}} The AT URI and the bsky.app URL, with the handle, date and text when the Post has them
 */
export function formatPost(post) {
  const { uri } = post;
  const [did, , rkey] = _.chain(uri).replace('at://', '').split('/').value();

  return {
    uri,
    url: `https://bsky.app/profile/${did}/post/${rkey}`,
    ..._.chain(post)
      .pick(['handle', 'createdAt', 'text'])
      .omitBy(_.isNil)
      .value(),
  };
}
