import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from './callApi.js';
import { formatPost } from './formatPost.js';
import { getConfig } from './getConfig.js';
import { resolvePostRef } from './resolvePostRef.js';

export let __;

const COLLECTION = 'app.bsky.feed.post';

/**
 * Delete one of my Posts
 * @param {object} options - Options of the command
 * @param {string} options.ref - AT URI or bsky.app URL of the Post. Throws BLUESKY_INVALID_ARGUMENT when the Post cannot be reached
 * @returns {Promise<object>} The Post it deleted, formatted. Throws BLUESKY_NOT_OWN_POST, before any write, when the Post belongs to another account
 */
export async function postDelete(options) {
  const post = await __.resolvePostRef(options.ref, { argument: 'post' });

  // The tokens file holds the sessions of the DIDs that logged in
  const { tokens } = await __.getConfig();
  const [repo] = _.keys(tokens.sessions);
  const [did, , rkey] = _.chain(post.uri)
    .replace('at://', '')
    .split('/')
    .value();
  if (did !== repo) {
    throw firostError(
      'BLUESKY_NOT_OWN_POST',
      `Cannot delete ${post.uri}: it belongs to another account`,
    );
  }

  await __.callApi('com.atproto.repo.deleteRecord', {
    method: 'POST',
    body: { repo, collection: COLLECTION, rkey },
  });
  return formatPost(post);
}

__ = {
  callApi,
  getConfig,
  resolvePostRef,
};
