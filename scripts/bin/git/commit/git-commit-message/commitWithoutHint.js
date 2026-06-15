import { _, pMap } from 'golgoth';
import { absolute, dirname, read } from 'firost';
import Gilmore from 'gilmore';

export const commitWithoutHint = {
  /**
   * @returns {Promise<string>} System prompt for diff-only mode
   */
  async getPrompt() {
    return read(absolute(dirname(), 'prompt-without-hint.md'));
  },

  /**
   * Returns git diff of all staged files, excluding noise.
   * @returns {Promise<string>} Diff output, or empty string if nothing staged
   */
  async getDiff() {
    const repo = Gilmore();
    const stagedFiles = await repo.stagedFiles();

    const excludedFiles = ['yarn.lock'];
    const cleanStagedFiles = _.reject(stagedFiles, (filepath) => {
      return excludedFiles.includes(filepath);
    });

    const arrayDiff = await pMap(cleanStagedFiles, async (filepath) => {
      return repo.run(`diff --cached -- ${filepath}`);
    });

    return _.join(arrayDiff, '\n');
  },
};
