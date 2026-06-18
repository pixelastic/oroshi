import { _, pMap } from 'golgoth';
import { absolute, exists, gitRoot } from 'firost';
import Gilmore from 'gilmore';

/**
 * Retrieves the name of a deleted plan by checking staged files for removed plan sentinels.
 * @returns {Promise<string|null>} The name of the deleted plan if found, or null if no deleted plan is detected.
 */
export async function getDeletedPlanName() {
  const repo = Gilmore();
  const stagedPaths = await repo.stagedFiles();
  const results = await pMap(stagedPaths, async (filepath) => {
    if (!filepath.startsWith('plans/')) return null;
    if (!filepath.endsWith('/PRD.md') && !filepath.endsWith('/state.json'))
      return null;
    const fileExists = await exists(absolute(gitRoot(), filepath));
    return fileExists ? null : filepath;
  });
  const deletedSentinels = _.compact(results);
  if (!deletedSentinels.length) {
    return null;
  }
  return deletedSentinels[0].split('/')[1];
}
