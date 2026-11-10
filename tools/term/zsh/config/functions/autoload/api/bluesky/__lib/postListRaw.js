import { _ } from 'golgoth';
import { firostError } from 'firost';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { callApi } from './callApi.js';
import { callPublicApi } from './callPublicApi.js';
import { formatPost } from './formatPost.js';
import { getConfig } from './getConfig.js';

export let __;

const COLLECTION = 'app.bsky.feed.post';
const DEFAULT_LIMIT = 25;
const MAX_LIMIT = 100;

/**
 * List the Posts of an account as raw lines, newest first. It lists mine by default. A line holds the AT URI, the date of creation, then the text
 * @param {object} [options] - List options
 * @param {string} [options.actor] - Handle of another account, to list its Posts instead of mine. It needs no login
 * @param {string|number} [options.limit] - Maximum number of Posts, from 1 to 100. Throws BLUESKY_INVALID_ARGUMENT before any call when it is not an integer in that range
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function postListRaw(options = {}) {
  const limit = __.parseLimit(options.limit);

  if (options.actor) {
    return await __.listActor(options.actor, limit);
  }

  // The tokens file holds the sessions of the DIDs that logged in
  const { tokens } = await __.getConfig();
  const [repo] = _.keys(tokens.sessions);
  const response = await __.callApi('com.atproto.repo.listRecords', {
    query: { repo, collection: COLLECTION, limit },
  });

  return _.chain(response.records)
    .orderBy('value.createdAt', 'desc')
    .take(limit)
    .map((record) => __.toLine(record))
    .join('\n')
    .value();
}

__ = {
  /**
   * List the Posts of another account, from the public AppView
   * @param {string} actor - Handle of the account, with or without the @
   * @param {number} limit - Maximum number of Posts
   * @returns {Promise<string>} Raw lines, joined with a newline
   */
  async listActor(actor, limit) {
    const response = await __.callPublicApi('app.bsky.feed.getAuthorFeed', {
      query: {
        actor: _.trimStart(actor, '@'),
        filter: 'posts_no_replies',
        limit,
      },
    });

    // The feed holds the reposts of the account, that are not its Posts
    return _.chain(response.feed)
      .reject('reason')
      .map(({ post }) => __.toLine({ uri: post.uri, value: post.record }))
      .join('\n')
      .value();
  },
  /**
   * Check the limit of the command, and turn it into a number
   * @param {string|number} [limit] - Limit as typed, or undefined for the default
   * @returns {number} The limit
   */
  parseLimit(limit) {
    if (_.isUndefined(limit)) {
      return DEFAULT_LIMIT;
    }

    const isInteger = /^\d+$/.test(_.toString(limit));
    const number = Number(limit);
    if (!isInteger || number < 1 || number > MAX_LIMIT) {
      throw firostError(
        'BLUESKY_INVALID_ARGUMENT',
        `Invalid --limit ${limit}: pass an integer from 1 to ${MAX_LIMIT}`,
      );
    }
    return number;
  },
  /**
   * Turn one record of listRecords into a raw line
   * @param {object} record - The record, as returned by the PDS
   * @returns {string} The AT URI, the date and the text, separated by ▮
   */
  toLine(record) {
    const { uri, createdAt, text } = formatPost({
      uri: record.uri,
      createdAt: record.value.createdAt,
      text: record.value.text,
    });
    return _.chain([uri, createdAt, text])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },
  callApi,
  callPublicApi,
  getConfig,
};
