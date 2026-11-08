import { _, pMap } from 'golgoth';
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
 * With --thread, a line of three dashes splits the Draft into a chain of posts, validated together and published one by one.
 * Validation runs before any network write, and the blobs are uploaded last.
 * Mentions are resolved to DIDs and link cards are fetched before the preview and the write, so --dry-run calls the API when mentions exist, and fetches the first link.
 * @param {object} options - Options of the command
 * @param {string} [options.text] - Markdown given with --text
 * @param {string} [options.textFile] - Path of the Markdown file given with --text-file, which wins over the text
 * @param {boolean} [options.dryRun] - Preview the posts, and write nothing
 * @param {boolean} [options.noEmbed] - Attach no link card
 * @param {string} [options.replyTo] - AT URI or bsky.app URL of the Post to reply to. With --thread, the first post replies to it
 * @param {boolean} [options.thread] - Split the Draft into a Thread on each line of three dashes
 * @returns {Promise<object|object[]>} The URI and the web URL of the created Post, with its `warnings` when there are some (one such object per post with --thread), or the preview with --dry-run
 */
export async function postCreate(options) {
  const { file, directory, markdown } = await __.readDraft(options);
  const parsedPosts = __.parsePostMarkdown(markdown, {
    directory,
    thread: options.thread,
  });

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
  const published = await __.publishPosts(posts, repo);

  // A Thread returns every post, a single post only itself
  return options.thread ? published : published[0];
}

__ = {
  /**
   * Publish the posts one by one, each replying to the previous one
   * The first post replies to the target of --reply-to, if any. The root stays
   * the root of the target, or the first post.
   * @param {object[]} posts - Posts returned by resolveLinkCards
   * @param {string} repo - DID of the account that publishes
   * @returns {Promise<object[]>} For each post, its `uri` and `url`, with its `warnings` when there are some. Throws BLUESKY_THREAD_INTERRUPTED, which lists the published posts, when a post fails after the first one
   */
  async publishPosts(posts, repo) {
    const target = _.get(posts, '0.replyTo');
    let root = _.get(target, 'root');
    let parent = target ? _.pick(target, ['uri', 'cid']) : null;
    const published = [];

    try {
      await pMap(
        posts,
        async (post) => {
          const reply = parent ? { root, parent } : null;
          const response = await __.publishPost(post, repo, reply);
          parent = _.pick(response, ['uri', 'cid']);
          root = root ?? parent;

          const { warnings } = post;
          const formatted = __.formatPost(response);
          published.push(
            _.isEmpty(warnings) ? formatted : { ...formatted, warnings },
          );
        },
        { concurrency: 1 },
      );
    } catch (error) {
      if (_.isEmpty(published)) {
        throw error;
      }
      const urls = _.map(published, ({ uri, url }) => `- ${uri} ${url}`);
      throw firostError(
        'BLUESKY_THREAD_INTERRUPTED',
        `Post ${published.length + 1}/${posts.length} failed: ${error.message}\nAlready published:\n${_.join(urls, '\n')}`,
      );
    }

    return published;
  },
  /**
   * Create the record of one post, with its embed
   * @param {object} post - Post returned by resolveLinkCards
   * @param {string} repo - DID of the account that publishes
   * @param {{root: object, parent: object}|null} reply - Reply of the record, or null for a top-level post
   * @returns {Promise<{uri: string, cid: string}>} The response of createRecord
   */
  async publishPost(post, repo, reply) {
    const { text, facets, images, card } = post;

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
      ...(reply ? { reply } : {}),
      createdAt: new Date().toISOString(),
    };
    return await __.callApi('com.atproto.repo.createRecord', {
      method: 'POST',
      body: { repo, collection: COLLECTION, record },
    });
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
