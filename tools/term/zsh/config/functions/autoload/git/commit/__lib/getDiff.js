import { _, pMap } from 'golgoth';
import { getRepo } from './config.js';
import { redactSecrets } from './redactSecrets.js';

/**
 * Returns git diff of staged files, excluding specified files.
 * 100%-similarity renames get a "Files renamed:" fallback block instead of a diff.
 * @param {string[]} excludedFiles - Files to exclude from the diff
 * @returns {Promise<string>} Diff output with optional rename/binary fallback blocks
 */
export async function getDiff(excludedFiles) {
  const repo = getRepo();
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
    return repo.run(['diff', '--cached', '-M', '--', file.name]);
  });
  const contentDiff = _.join(arrayDiff, '\n').trim();

  // Find binary files (diffable files with empty diff output)
  const binaries = [];
  _.each(diffable, (file, index) => {
    if (!arrayDiff[index]?.trim()) {
      binaries.push(file);
    }
  });

  // Assemble blocks: content, renames, binaries
  const blocks = [];

  if (contentDiff) {
    blocks.push(contentDiff);
  }

  if (renames.length > 0) {
    const renameList = _.map(
      renames,
      (file) => `- ${file.from} \u2192 ${file.name}`,
    ).join('\n');
    blocks.push(`Files renamed:\n${renameList}`);
  }

  if (binaries.length > 0) {
    const binaryList = _.map(binaries, (file) => `- ${file.name}`).join('\n');
    blocks.push(`Binary files added:\n${binaryList}`);
  }

  return redactSecrets(blocks.join('\n\n'));
}
