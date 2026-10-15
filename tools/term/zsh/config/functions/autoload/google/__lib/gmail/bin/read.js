import { runBin } from '@oroshi/api-shared/runBin.js';
import { gmailRead } from '../read.js';

await runBin(async () => {
  const [account, threadId] = process.argv.slice(2);
  const messages = await gmailRead(account, threadId);
  process.stdout.write(`${JSON.stringify(messages, null, 2)}\n`);
});
