import { run } from 'firost';

export let __;

/**
 * Returns the absolute path to the plan directory for the current worktree.
 * Returns null if not in a ralph worktree or if plan-directory fails.
 * @returns {Promise<string|null>} Absolute path to plan dir, or null
 */
export async function getPlanDir() {
  try {
    const { stdout } = await __.run('plan-directory', { stdout: false });
    return stdout.trim();
  } catch {
    return null;
  }
}

__ = {
  run,
};
