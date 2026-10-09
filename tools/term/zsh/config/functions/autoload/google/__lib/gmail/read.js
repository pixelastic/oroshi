import { googleAuth } from '../google/auth.js';
import { gmailThreads } from './threads.js';

/**
 * Read every mail of a thread
 * @param {string} account - "pro" or "perso"
 * @param {string} threadId - Thread id
 * @returns {Promise<object[]>} Messages { id, from, to, subject, date, snippet, body, attachments }, oldest first
 */
export async function gmailRead(account, threadId) {
  const auth = await googleAuth(account);
  return await gmailThreads.get(auth, threadId);
}
