import { _, pMap } from 'golgoth';
import { getRepo } from './config.js';
import { redactSecrets } from './redactSecrets.js';

export let __;

/**
 * Returns git diff of staged files, excluding specified files.
 * 100%-similarity renames get a "Files renamed:" fallback block instead of a diff.
 * @param {string[]} excludedFiles - Files to exclude from the diff
 * @returns {Promise<string>} Diff output with optional rename/binary fallback blocks
 */
export async function getDiff(excludedFiles) {
  const repo = __.getRepo();
  const allFiles = await repo.stagedFilesWithStatus();

  const cleanFiles = _.reject(allFiles, (file) => {
    return excludedFiles.includes(file.name);
  });

  // Classify into rename-only vs diffable
  const renames = [];
  const diffable = [];
  _.each(cleanFiles, (file) => {
    if (file.status === 'renamed' && file.similarity === 100) {
      renames.push(file);
      return;
    }
    diffable.push(file);
  });

  // Diff non-rename files
  const arrayDiff = await pMap(diffable, async (file) => {
    return repo.run([
      'diff',
      '--cached',
      '--no-textconv',
      '-M',
      '--',
      file.name,
    ]);
  });
  const contentDiff = _.chain(arrayDiff)
    .reject(__.isBinaryDiff)
    .join('\n')
    .trim()
    .value();

  // Find binary files (diffable files with empty diff output)
  const binaries = [];
  _.each(diffable, (file, index) => {
    if (__.isBinaryDiff(arrayDiff[index])) {
      binaries.push(file);
    }
  });

  // Assemble blocks: content, renames, binaries
  const blocks = [];

  if (contentDiff) {
    blocks.push(contentDiff);
  }

  if (!_.isEmpty(renames)) {
    const renameList = _.chain(renames)
      .map((file) => `- ${file.from} \u2192 ${file.name}`)
      .join('\n')
      .value();
    blocks.push(`Files renamed:\n${renameList}`);
  }

  if (!_.isEmpty(binaries)) {
    const binaryList = _.chain(binaries)
      .map((file) => `- ${file.name}`)
      .join('\n')
      .value();
    blocks.push(`Binary files added:\n${binaryList}`);
  }

  return redactSecrets(blocks.join('\n\n'));
}

__ = {
  /**
   * Checks if a diff carries no readable content.
   * With --no-textconv, SQLite and other binaries print "Binary files differ".
   * @param {string} [diff] - Diff output of a single file
   * @returns {boolean} True if the diff is empty or a binary placeholder
   */
  isBinaryDiff(diff) {
    return !diff?.trim() || /^Binary files /m.test(diff);
  },
  getRepo,
};
