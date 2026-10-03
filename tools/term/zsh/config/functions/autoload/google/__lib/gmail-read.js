import { fileURLToPath } from 'node:url';
import { gmailFormatMarkdown } from './gmailFormatMarkdown.js';
import { gmailMessages } from './gmailMessages.js';
import { googleAuth } from './googleAuth.js';

/**
 * Read one mail as Markdown
 * @param {string} account - "pro" or "perso"
 * @param {string} id - Message id
 * @returns {Promise<string>} Markdown
 */
export async function gmailRead(account, id) {
  const auth = await googleAuth(account);
  const message = await gmailMessages.get(auth, id);
  return gmailFormatMarkdown(message);
}

// CLI entry
const currentFile = fileURLToPath(import.meta.url);
if (process.argv[1] === currentFile) {
  const [account, id] = process.argv.slice(2);
  const markdown = await gmailRead(account, id);
  process.stdout.write(`${markdown}\n`);
}
