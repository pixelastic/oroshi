import { fileURLToPath } from 'node:url';
import { _, dayjs, pMap } from 'golgoth';
import { googleAuth } from '../google/auth.js';
import { gmailFormatRaw } from './formatRaw.js';
import { gmailLimits } from './limits.js';
import { gmailThreads } from './threads.js';

export let __;

const IMPORTANT_QUERY = 'in:inbox is:important';
const OTHERS_QUERY = 'in:inbox -is:important';

/**
 * List inbox threads as raw lines, one per thread. The threads of the limit come
 * from the Gmail inbox sections (important first, then everything else), then
 * unread threads go before read threads, each group sorted by last message date,
 * most recent first
 * @param {string} account - "pro" or "perso"
 * @param {number} limit - Maximum number of threads
 * @returns {Promise<string[]>} Raw lines, unread threads first
 */
export async function gmailInboxRaw(account, limit = gmailLimits.inbox) {
  const auth = await __.googleAuth(account);
  const important = await gmailThreads.list(auth, {
    query: IMPORTANT_QUERY,
    limit,
  });
  const remaining = limit - important.length;
  const others =
    remaining > 0
      ? await gmailThreads.list(auth, { query: OTHERS_QUERY, limit: remaining })
      : [];
  return pMap(
    _.chain([...important, ...others])
      .uniqBy('threadId')
      .take(limit)
      .orderBy((thread) => dayjs(thread.lastMessageDate).valueOf() || 0, 'desc')
      .partition('unread')
      .flatten()
      .value(),
    gmailFormatRaw,
  );
}

__ = { googleAuth };

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
