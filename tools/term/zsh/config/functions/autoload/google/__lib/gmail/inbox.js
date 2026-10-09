import { pMap } from 'golgoth';
import { gmailFormat } from './format.js';
import { gmailInboxRaw } from './inboxRaw.js';
import { gmailLimits } from './limits.js';
import { gmailParseRaw } from './parseRaw.js';

export let __;

const DEFAULT_WIDTH = 80;

/**
 * List inbox threads as a terminal table
 * @param {string} account - "pro" or "perso"
 * @param {object} options - Display options
 * @param {number} options.limit - Maximum number of threads
 * @param {number} options.width - Terminal width
 * @returns {Promise<string>} Table
 */
export async function gmailInbox(
  account,
  { limit = gmailLimits.inbox, width = DEFAULT_WIDTH } = {},
) {
  const lines = await __.gmailInboxRaw(account, limit);
  const threads = await pMap(lines, gmailParseRaw);
  return gmailFormat(threads, { width });
}

__ = { gmailInboxRaw };
