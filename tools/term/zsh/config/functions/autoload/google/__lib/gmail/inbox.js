import { fileURLToPath } from 'node:url';
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

// CLI entry
const currentFile = fileURLToPath(import.meta.url);
if (process.argv[1] === currentFile) {
  const [account, limit, width] = process.argv.slice(2);
  const table = await gmailInbox(account, {
    limit: Number(limit) || gmailLimits.inbox,
    width: Number(width) || DEFAULT_WIDTH,
  });
  process.stdout.write(`${table}\n`);
}
