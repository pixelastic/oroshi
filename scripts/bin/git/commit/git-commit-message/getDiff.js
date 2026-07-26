import { _, pMap } from 'golgoth';
import Gilmore from 'gilmore';

/**
 * Returns git diff of staged files, excluding specified files.
 * @param {string[]} excludedFiles - Files to exclude from the diff
 * @returns {Promise<string>} Diff output, or binary fallback message
 */
export async function getDiff(excludedFiles) {
  const repo = Gilmore();
  const stagedFiles = await repo.stagedFiles();

  const cleanStagedFiles = _.reject(stagedFiles, (filepath) => {
    return excludedFiles.includes(filepath);
  });

  const arrayDiff = await pMap(cleanStagedFiles, async (filepath) => {
    return repo.run(`diff --cached -- ${filepath}`);
  });

  const diff = _.join(arrayDiff, '\n').trim();

  // If still no diff, it's only binary files. We add them then:
  if (!diff) {
    const fileList = _.map(cleanStagedFiles, (f) => `- ${f}`).join('\n');
    return `Binary files added:\n${fileList}`;
  }
  return diff;
}
