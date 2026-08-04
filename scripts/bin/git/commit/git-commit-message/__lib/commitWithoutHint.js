import { absolute, dirname, read } from 'firost';
import { getDiff } from './getDiff.js';

export const commitWithoutHint = {
  /**
   * @returns {Promise<string>} System prompt for diff-only mode
   */
  async getPrompt() {
    return read(absolute(dirname(), '../__prompts/prompt-without-hint.md'));
  },

  /**
   * Returns git diff of all staged files, excluding noise.
   * @returns {Promise<string>} Diff output, or empty string if nothing staged
   */
  async getDiff() {
    return getDiff(['yarn.lock']);
  },
};
