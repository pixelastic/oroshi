import { runBin } from '@oroshi/api-shared/runBin.js';
import { gmailInboxRaw } from '../inboxRaw.js';
import { gmailLimits } from '../limits.js';

await runBin(async () => {
  const [account, limit] = process.argv.slice(2);
  const lines = await gmailInboxRaw(
    account,
    Number(limit) || gmailLimits.inbox,
  );
  process.stdout.write(lines.map((line) => `${line}\n`).join(''));
});
