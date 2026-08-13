import { _ } from 'golgoth';
import { absolute, dirname, read } from 'firost';
import { getCommitHint } from './getCommitHint.js';
import { getDiff } from './getDiff.js';
import { getPlanDir } from './getPlanDir.js';

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
   * Returns git diff of staged files, excluding plan noise siblings.
   * @returns {Promise<string>} Diff output, or empty string if no relevant files
   */
  async getDiff() {
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
    return getDiff(excludedFiles);
  },
};
