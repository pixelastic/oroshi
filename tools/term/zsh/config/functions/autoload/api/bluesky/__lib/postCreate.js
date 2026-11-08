import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from './callApi.js';
import { formatPost } from './formatPost.js';
import { getConfig } from './getConfig.js';
import { parsePostMarkdown } from './parsePostMarkdown.js';
import { previewPosts } from './previewPosts.js';
import { readDraft } from './readDraft.js';
import { resolveLinkCards } from './resolveLinkCards.js';
import { resolveMentions } from './resolveMentions.js';
import { resolvePostRef } from './resolvePostRef.js';
import { uploadImages } from './uploadImages.js';
import { uploadLinkCard } from './uploadLinkCard.js';
import { validatePost } from './validatePost.js';

export let __;

const COLLECTION = 'app.bsky.feed.post';

/**
 * Publish a Post with its facets, and its images or link card, or preview it
 * Validation runs before any network write, and the blobs are uploaded last.
 * Mentions are resolved to DIDs and link cards are fetched before the preview and the write, so --dry-run calls the API when mentions exist, and fetches the first link.
 * @param {object} options - Options of the command
 * @param {string} [options.text] - Markdown given with --text
 * @param {string} [options.textFile] - Path of the Markdown file given with --text-file, which wins over the text
 * @param {boolean} [options.dryRun] - Preview the posts, and write nothing
 * @param {boolean} [options.noEmbed] - Attach no link card
 * @param {string} [options.replyTo] - AT URI or bsky.app URL of the Post to reply to
 * @returns {Promise<object|object[]>} The URI and the web URL of the created Post, with its `warnings` when there are some, or the preview with --dry-run
 */
export async function postCreate(options) {
  const { file, directory, markdown } = await __.readDraft(options);
  const parsedPosts = __.parsePostMarkdown(markdown, { directory });

  // Abort on any error, before any network write. Warnings do not block
  const violations = await __.validatePost(parsedPosts);
  const errors = _.filter(violations, { level: 'error' });
  if (!_.isEmpty(errors)) {
    const lines = _.map(errors, ({ line, code, message }) => {
      return `${file}:${line} ${code} ${message}`;
    });
    const hasMissingAlt = _.some(errors, { code: 'missing-alt' });
    throw firostError(
      hasMissingAlt ? 'BLUESKY_MISSING_ALT' : 'BLUESKY_INVALID_POST',
      _.join(lines, '\n'),
    );
  }

  // An unreachable target aborts here, before anything else is fetched
  const [first, ...others] = parsedPosts;
  const replyTo = _.isNil(options.replyTo)
    ? null
    : await __.resolvePostRef(options.replyTo);
  const repliedPosts = replyTo
    ? [{ ...first, replyTo }, ...others]
    : parsedPosts;

  // An unknown handle aborts here, so that no one is mentioned by mistake
  const mentioned = await __.resolveMentions(repliedPosts);

  // An unreachable page only gives a warning, so the post goes without a card
  const posts = await __.resolveLinkCards(mentioned, {
    noEmbed: options.noEmbed,
  });

  if (options.dryRun) {
    return await __.previewPosts(posts);
  }

  // The tokens file holds the sessions of the DIDs that logged in
  const { tokens } = await __.getConfig();
  const [repo] = _.keys(tokens.sessions);
  const [{ text, facets, images, card, warnings, replyTo: target }] = posts;

  // One embed per post: the images win, and resolveLinkCards left no card
  let embed = null;
  if (!_.isEmpty(images)) {
    embed = await __.uploadImages(images);
  } else if (card) {
    embed = await __.uploadLinkCard(card);
  }
  const record = {
    $type: COLLECTION,
    text,
    ...(_.isEmpty(facets) ? {} : { facets }),
    ...(embed ? { embed } : {}),
    ...(target ? { reply: __.buildReply(target) } : {}),
    createdAt: new Date().toISOString(),
  };
  const response = await __.callApi('com.atproto.repo.createRecord', {
    method: 'POST',
    body: { repo, collection: COLLECTION, record },
  });

  const published = __.formatPost(response);
  return _.isEmpty(warnings) ? published : { ...published, warnings };
}

__ = {
  /**
   * Build the reply of a record: the Thread root and the Parent
   * @param {{uri: string, cid: string, root: object}} target - Post to reply to, as returned by resolvePostRef
   * @returns {{root: object, parent: object}} The reply of the record
   */
  buildReply(target) {
    return { root: target.root, parent: _.pick(target, ['uri', 'cid']) };
  },

  callApi,
  formatPost,
  getConfig,
  parsePostMarkdown,
  previewPosts,
  readDraft,
  resolveLinkCards,
  resolveMentions,
  resolvePostRef,
  uploadImages,
  uploadLinkCard,
  validatePost,
};
