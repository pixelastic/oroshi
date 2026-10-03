import { fileURLToPath } from 'node:url';
import { googleAuth } from '../google/auth.js';
import { gmailFormatJson } from './formatJson.js';
import { gmailLimits } from './limits.js';
import { gmailMessages } from './messages.js';

/**
 * Search mails with a native Gmail query, as JSON
 * @param {string} account - "pro" or "perso"
 * @param {string} query - Gmail search query, passed untouched
 * @param {number} limit - Maximum number of mails
 * @returns {Promise<string>} JSON array
 */
export async function gmailSearch(account, query, limit = gmailLimits.search) {
  const auth = await googleAuth(account);
  const messages = await gmailMessages.list(auth, { query, limit });
  return gmailFormatJson(messages);
}

// CLI entry
const currentFile = fileURLToPath(import.meta.url);
if (process.argv[1] === currentFile) {
  const [account, query, limit] = process.argv.slice(2);
  const json = await gmailSearch(
    account,
    query,
    Number(limit) || gmailLimits.search,
  );
  process.stdout.write(`${json}\n`);
}
