import { mkdir, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { googleAuth } from '../google/auth.js';
import { gmailMessages } from './messages.js';

export let __;

/**
 * Download one attachment of a mail
 * @param {string} account - "pro" or "perso"
 * @param {object} options - Download options
 * @param {string} options.messageId - Message id
 * @param {string} options.partId - Part id, as listed by gmail-read
 * @param {string} [options.out] - Existing directory (keeps the remote filename)
 * or file path. Defaults to the current directory
 * @returns {Promise<string>} Path of the saved file
 */
export async function gmailAttachment(account, { messageId, partId, out }) {
  const auth = await __.googleAuth(account);
  const { filename, data } = await gmailMessages.getAttachment(auth, {
    messageId,
    partId,
  });
  const filepath = await __.resolveOutput(out, filename);
  await mkdir(path.dirname(filepath), { recursive: true });
  await writeFile(filepath, data);
  return filepath;
}

__ = {
  /**
   * Choose where to save the file. An existing directory receives the file
   * under its remote name. Any other value is used as the file path
   * @param {string} [out] - Value of --out
   * @param {string} filename - Remote filename
   * @returns {Promise<string>} Absolute file path
   */
  async resolveOutput(out, filename) {
    // No --out: save in the current directory
    if (!out) {
      return path.resolve(path.basename(filename));
    }
    const isDirectory = await stat(out)
      .then((info) => info.isDirectory())
      .catch(() => false);
    if (isDirectory) {
      return path.resolve(out, path.basename(filename));
    }
    return path.resolve(out);
  },

  googleAuth,
};
