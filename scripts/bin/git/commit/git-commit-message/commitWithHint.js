import { _, pMap } from 'golgoth';
import { absolute, dirname, read } from 'firost';
import Gilmore from 'gilmore';
import { getCommitHint } from './getCommitHint.js';
import { getPlanDir } from './getPlanDir.js';

export const commitWithHint = {
  /**
   * @returns {Promise<string>} System prompt with hint injected
   */
  async getPrompt() {
    const template = await read(absolute(dirname(), 'prompt-with-hint.md'));
    const commitHint = await getCommitHint();
    return template.replace('{{COMMIT_HINT}}', commitHint);
  },

  /**
   * Returns git diff of staged files, excluding plan noise siblings.
   * @returns {Promise<string>} Diff output, or empty string if no relevant files
   */
  async getDiff() {
    const repo = Gilmore();
    const stagedFiles = await repo.stagedFiles();

    const absolutePlanDir = await getPlanDir();
    const relativePlanDir = _.chain(absolutePlanDir)
      .split('/')
      .compact()
      .slice(-2)
      .join('/')
      .value();
    const excludedFiles = [
      'yarn.lock',
      `${relativePlanDir}/state.json`,
      `${relativePlanDir}/review-log.md`,
      `${relativePlanDir}/GUIDANCE.md`,
    ];
    const cleanStagedFiles = _.reject(stagedFiles, (filepath) => {
      return excludedFiles.includes(filepath);
    });

    const arrayDiff = await pMap(cleanStagedFiles, async (filepath) => {
      return repo.run(`diff --cached -- ${filepath}`);
    });

    return _.join(arrayDiff, '\n');
  },
};
