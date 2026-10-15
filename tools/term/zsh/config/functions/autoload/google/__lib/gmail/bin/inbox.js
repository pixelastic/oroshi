import { runBin } from '@oroshi/api-shared/runBin.js';
import { gmailInbox } from '../inbox.js';
import { gmailLimits } from '../limits.js';

const DEFAULT_WIDTH = 80;

await runBin(async () => {
  const [account, limit, width] = process.argv.slice(2);
  const table = await gmailInbox(account, {
    limit: Number(limit) || gmailLimits.inbox,
    width: Number(width) || DEFAULT_WIDTH,
  });
  process.stdout.write(`${table}\n`);
});
