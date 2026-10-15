import { runBin } from '@oroshi/api-shared/runBin.js';
import { gmailLimits } from '../limits.js';
import { gmailSearch } from '../search.js';

await runBin(async () => {
  const [account, query, limit] = process.argv.slice(2);
  const json = await gmailSearch(
    account,
    query,
    Number(limit) || gmailLimits.search,
  );
  process.stdout.write(`${json}\n`);
});
