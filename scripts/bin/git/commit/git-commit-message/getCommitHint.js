import { absolute, exists, read } from 'firost';
import { getPlanDir } from './getPlanDir.js';

export let __;

/**
 * Reads the COMMIT_HINT.md from the current worktree's plan directory.
 * Returns null if not in a ralph worktree or if the file is absent.
 * @returns {Promise<string|null>} Hint content or null
 */
export async function getCommitHint() {
  const planDir = await getPlanDir();
  if (!planDir) return false;

  const hintPath = absolute(planDir, 'COMMIT_HINT.md');
  if (!(await exists(hintPath))) return false;

  return read(hintPath);
}
