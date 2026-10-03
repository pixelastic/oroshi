import { fileURLToPath } from 'node:url';
import { googleAuth } from '../google/auth.js';
import { gmailFormat } from './format.js';
import { gmailLimits } from './limits.js';
import { gmailMessages } from './messages.js';

const DEFAULT_WIDTH = 80;

/**
 * List inbox mails as a terminal table
 * @param {string} account - "pro" or "perso"
 * @param {object} options - Display options
 * @param {number} options.limit - Maximum number of mails
 * @param {number} options.width - Terminal width
 * @returns {Promise<string>} Table
 */
export async function gmailInbox(
  account,
  { limit = gmailLimits.inbox, width = DEFAULT_WIDTH } = {},
) {
  const auth = await googleAuth(account);
  const messages = await gmailMessages.list(auth, {
    query: 'in:inbox',
    limit,
  });
  return gmailFormat(messages, { width });
}

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
