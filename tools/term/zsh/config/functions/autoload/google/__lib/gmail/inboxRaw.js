import { fileURLToPath } from 'node:url';
import { pMap } from 'golgoth';
import { googleAuth } from '../google/auth.js';
import { gmailFormatRaw } from './formatRaw.js';
import { gmailLimits } from './limits.js';
import { gmailThreads } from './threads.js';

/**
 * List inbox threads as raw lines, one per thread
 * @param {string} account - "pro" or "perso"
 * @param {number} limit - Maximum number of threads
 * @returns {Promise<string[]>} Raw lines, unread threads first
 */
export async function gmailInboxRaw(account, limit = gmailLimits.inbox) {
  const auth = await googleAuth(account);
  const threads = await gmailThreads.list(auth, {
    query: 'in:inbox',
    limit,
  });
  return pMap(threads, gmailFormatRaw);
}

// CLI entry
const currentFile = fileURLToPath(import.meta.url);
if (process.argv[1] === currentFile) {
  const [account, limit] = process.argv.slice(2);
  const lines = await gmailInboxRaw(
    account,
    Number(limit) || gmailLimits.inbox,
  );
  process.stdout.write(lines.map((line) => `${line}\n`).join(''));
}
