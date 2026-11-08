import { formatPost } from './formatPost.js';
import { resolvePostRef } from './resolvePostRef.js';

export let __;

/**
 * Read one Post
 * @param {object} options - Options of the command
 * @param {string} options.ref - AT URI or bsky.app URL of the Post. Throws BLUESKY_INVALID_ARGUMENT when the Post cannot be reached
 * @returns {Promise<object>} The Post, formatted
 */
export async function postRead(options) {
  const post = await __.resolvePostRef(options.ref, { argument: 'post' });
  return formatPost(post);
}

__ = {
  resolvePostRef,
};
