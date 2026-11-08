import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from './callApi.js';
import { formatPost } from './formatPost.js';
import { getConfig } from './getConfig.js';
import { parsePostMarkdown } from './parsePostMarkdown.js';
import { previewPosts } from './previewPosts.js';
import { readDraft } from './readDraft.js';
import { resolveMentions } from './resolveMentions.js';
import { validatePost } from './validatePost.js';

export let __;

const COLLECTION = 'app.bsky.feed.post';

/**
 * Publish a text Post with its facets, or preview it
 * Validation runs before any network write.
 * Mentions are resolved to DIDs before the preview and the write, so --dry-run calls the API when mentions exist.
 * @param {object} options - Options of the command
 * @param {string} [options.text] - Markdown given with --text
 * @param {string} [options.textFile] - Path of the Markdown file given with --text-file, which wins over the text
 * @param {boolean} [options.dryRun] - Preview the posts, and write nothing
 * @returns {Promise<object|object[]>} The URI and the web URL of the created Post, or the preview with --dry-run
 */
export async function postCreate(options) {
  const { file, markdown } = await __.readDraft(options);
  const parsedPosts = __.parsePostMarkdown(markdown);

  // Abort on any error, before any network write. Warnings do not block
  const errors = _.filter(__.validatePost(parsedPosts), { level: 'error' });
  if (!_.isEmpty(errors)) {
    const lines = _.map(errors, ({ line, code, message }) => {
      return `${file}:${line} ${code} ${message}`;
    });
    throw firostError('BLUESKY_INVALID_POST', _.join(lines, '\n'));
  }

  // An unknown handle aborts here, so that no one is mentioned by mistake
  const posts = await __.resolveMentions(parsedPosts);

  if (options.dryRun) {
    return __.previewPosts(posts);
  }

  // The tokens file holds the sessions of the DIDs that logged in
  const { tokens } = await __.getConfig();
  const [repo] = _.keys(tokens.sessions);
  const [{ text, facets }] = posts;
  const record = {
    $type: COLLECTION,
    text,
    ...(_.isEmpty(facets) ? {} : { facets }),
    createdAt: new Date().toISOString(),
  };
  const response = await __.callApi('com.atproto.repo.createRecord', {
    method: 'POST',
    body: { repo, collection: COLLECTION, record },
  });

  return __.formatPost(response);
}

__ = {
  callApi,
  formatPost,
  getConfig,
  parsePostMarkdown,
  previewPosts,
  readDraft,
  resolveMentions,
  validatePost,
};
