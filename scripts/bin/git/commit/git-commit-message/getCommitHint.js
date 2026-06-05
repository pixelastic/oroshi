import { absolute, exists, read, run } from 'firost';

export let __;

/**
 * Reads the COMMIT_HINT.md from the current worktree's plan directory.
 * Returns null if not in a ralph worktree or if the file is absent.
 * @returns {Promise<string|null>} Hint content or null
 */
export async function getCommitHint() {
  const planDir = await __.getPlanDir();
  if (!planDir) return null;

  const hintPath = absolute(planDir.trim(), 'COMMIT_HINT.md');
  if (!(await __.hintExists(hintPath))) return null;

  return __.readHint(hintPath);
}

__ = {
  /**
   * Returns the plan directory path by calling plan-directory subprocess.
   * @returns {Promise<string|null>} Path or null if plan-directory fails
   */
  async getPlanDir() {
    try {
      const { stdout } = await run('plan-directory', { stdout: false });
      return stdout;
    } catch {
      return null;
    }
  },
  /**
   * Checks if a hint exists at the specified path.
   * @param {string} hintPath - The path to the hint to check for existence
   * @returns {boolean} True if the hint exists, false otherwise
   */
  hintExists(hintPath) {
    return exists(hintPath);
  },
  /**
   * Reads a hint from the specified file path.
   * @param {string} hintPath - The file path to the hint file to be read
   * @returns {*} The content of the hint file
   */
  readHint(hintPath) {
    return read(hintPath);
  },
};
