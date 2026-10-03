import { fileURLToPath } from 'node:url';
import { _ } from 'golgoth';
import { gmailFormatRaw } from './gmailFormatRaw.js';
import { gmailMessages } from './gmailMessages.js';
import { googleAuth } from './googleAuth.js';

const DEFAULT_LIMIT = 20;

/**
 * List inbox mails as raw lines, one per mail
 * @param {string} account - "pro" or "perso"
 * @param {number} limit - Maximum number of mails
 * @returns {string[]} Raw lines
 */
export async function gmailInboxRaw(account, limit = DEFAULT_LIMIT) {
  const auth = await googleAuth(account);
  const messages = await gmailMessages.list(auth, {
    query: 'in:inbox',
    limit,
  });
  return _.map(messages, gmailFormatRaw);
}

// CLI entry
const currentFile = fileURLToPath(import.meta.url);
if (process.argv[1] === currentFile) {
  const [account, limit] = process.argv.slice(2);
  const lines = await gmailInboxRaw(account, Number(limit) || DEFAULT_LIMIT);
  process.stdout.write(lines.map((line) => `${line}\n`).join(''));
}
