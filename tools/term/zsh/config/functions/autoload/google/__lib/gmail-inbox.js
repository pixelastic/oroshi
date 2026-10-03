import { fileURLToPath } from 'node:url';
import { gmailFormat } from './gmailFormat.js';
import { gmailMessages } from './gmailMessages.js';
import { googleAuth } from './googleAuth.js';

const DEFAULT_LIMIT = 20;
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
  { limit = DEFAULT_LIMIT, width = DEFAULT_WIDTH } = {},
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
    limit: Number(limit) || DEFAULT_LIMIT,
    width: Number(width) || DEFAULT_WIDTH,
  });
  process.stdout.write(`${table}\n`);
}
