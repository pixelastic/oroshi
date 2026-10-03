import { fileURLToPath } from 'node:url';
import { googleAuth } from '../google/auth.js';
import { gmailMessages } from './messages.js';

/**
 * Read one mail
 * @param {string} account - "pro" or "perso"
 * @param {string} id - Message id
 * @returns {Promise<object>} { id, from, to, subject, date, snippet, body, attachments }
 */
export async function gmailRead(account, id) {
  const auth = await googleAuth(account);
  return await gmailMessages.get(auth, id);
}

// CLI entry
const currentFile = fileURLToPath(import.meta.url);
if (process.argv[1] === currentFile) {
  const [account, id] = process.argv.slice(2);
  const message = await gmailRead(account, id);
  process.stdout.write(`${JSON.stringify(message, null, 2)}\n`);
}
