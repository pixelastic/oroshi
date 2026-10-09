import { gmailRead } from '../read.js';

const [account, threadId] = process.argv.slice(2);
const messages = await gmailRead(account, threadId);
process.stdout.write(`${JSON.stringify(messages, null, 2)}\n`);
