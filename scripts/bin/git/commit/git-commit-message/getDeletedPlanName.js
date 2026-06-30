import { _ } from 'golgoth';
import Gilmore from 'gilmore';

/**
 * Retrieves the name of a deleted plan by checking staged files for removed plan sentinels.
 * @returns {Promise<string|null>} The name of the deleted plan if found, or null if no deleted plan is detected.
 */
export async function getDeletedPlanName() {
  const repo = Gilmore();
  const allStatus = await repo.status();
  if (!allStatus) return null;

  const deletedSentinels = _.filter(allStatus, ({ name, status }) => {
    if (!name.startsWith('plans/')) return false;

    const isSentinel = name.endsWith('/PRD.md') || name.endsWith('/state.json');
    if (!isSentinel) return false;

    return status === 'deleted';
  });

  if (!deletedSentinels.length) return null;
  return deletedSentinels[0].name.split('/')[1];
}
