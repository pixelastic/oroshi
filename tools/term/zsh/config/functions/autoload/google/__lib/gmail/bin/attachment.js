import { gmailAttachment } from '../attachment.js';

const [account, messageId, partId, out] = process.argv.slice(2);
const filepath = await gmailAttachment(account, {
  messageId,
  partId,
  out,
});
process.stdout.write(`${filepath}\n`);
