import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callPublicApi } from './callPublicApi.js';
import { resolveHandle } from './resolveHandle.js';

export let __;

const COLLECTION = 'app.bsky.feed.post';
const AT_URI = new RegExp(
  `^at://([^/]+)/${_.escapeRegExp(COLLECTION)}/([^/]+)$`,
);
const WEB_URL = /^https:\/\/bsky\.app\/profile\/([^/]+)\/post\/([^/]+)$/;

/**
 * Resolve the Post a reply goes to: its URI, its CID and the root of its Thread
 * The reference is an AT URI or a bsky.app URL, with a handle or a DID.
 * Every failure to reach a Post is a BLUESKY_INVALID_ARGUMENT, so that nothing is sent.
 * @param {string} ref - AT URI or bsky.app URL of the Post
 * @param {object} [options] - Options of the resolver
 * @param {string} [options.argument] - Name of the argument that holds the reference, to name it in the errors
 * @returns {Promise<{uri: string, cid: string, text: string, handle: string, createdAt: string, root: {uri: string, cid: string}}>} The target, with its `text` and the `root` of its Thread (the target itself when it is not a reply)
 */
export async function resolvePostRef(ref, options = {}) {
  const { argument = '--reply-to' } = options;
  const invalid = (reason) => {
    return firostError(
      'BLUESKY_INVALID_ARGUMENT',
      `Invalid ${argument} ${ref}: ${reason}`,
    );
  };

  const match = AT_URI.exec(ref) || WEB_URL.exec(ref);
  if (!match) {
    throw invalid('pass an AT URI or a bsky.app post URL');
  }

  // The AppView needs a DID in the AT URI
  const [, authority, rkey] = match;
  const did = _.startsWith(authority, 'did:')
    ? authority
    : await __.resolveHandle(authority);
  if (!did) {
    throw invalid(`cannot resolve the handle ${authority}`);
  }

  const uri = `at://${did}/${COLLECTION}/${rkey}`;
  let response;
  try {
    response = await __.callPublicApi('app.bsky.feed.getPostThread', {
      query: { uri, depth: 0, parentHeight: 0 },
    });
  } catch (error) {
    // The AppView answers 400 for a Post that does not exist
    const isMissing =
      error.code === 'BLUESKY_REQUEST_FAILED' &&
      _.startsWith(error.message, '400');
    if (isMissing) {
      throw invalid(`cannot find the post ${uri}`);
    }
    throw error;
  }

  const post = _.get(response, 'thread.post');
  if (!post) {
    throw invalid(`cannot find the post ${uri}`);
  }

  const { cid, record } = post;
  return {
    uri: post.uri,
    cid,
    text: record.text,
    handle: post.author.handle,
    createdAt: record.createdAt,
    root: _.get(record, 'reply.root', { uri: post.uri, cid }),
  };
}

__ = {
  callPublicApi,
  resolveHandle,
};
