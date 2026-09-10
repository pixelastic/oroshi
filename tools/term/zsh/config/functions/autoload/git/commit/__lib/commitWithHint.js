import { absolute, dirname, read } from 'firost';
import { getCommitHint } from './getCommitHint.js';
import { getDiff } from './getDiff.js';

export let __;

export const commitWithHint = {
  /**
   * @returns {Promise<string>} System prompt with hint injected
   */
  async getPrompt() {
    const template = await read(
      absolute(dirname(), '../__prompts/prompt-with-hint.md'),
    );
    const commitHint = await getCommitHint();
    return template.replace('{{COMMIT_HINT}}', commitHint);
  },

  /**
   * Returns git diff of staged files, excluding noise.
   * @returns {Promise<string>} Diff output, or empty string if no relevant files
   */
  async getDiff() {
    return __.getDiff(['yarn.lock']);
  },
};

__ = {
  getDiff,
};
