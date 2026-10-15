import { runBin } from '@oroshi/api-shared/runBin.js';
import { gmailAttachment } from '../attachment.js';

await runBin(async () => {
  const [account, messageId, partId, out] = process.argv.slice(2);
  const filepath = await gmailAttachment(account, {
    messageId,
    partId,
    out,
  });
  process.stdout.write(`${filepath}\n`);
});
