import { _ } from 'golgoth';
import { firostError } from 'firost';

/**
 * Throw when the Scenario ID anchor is missing
 * @param {number|string} [scenarioId] - Scenario ID, as received by the helper
 * @param {string} usage - Right usage of the helper, shown in the message
 */
export function assertScenarioId(scenarioId, usage) {
  if (!_.isUndefined(scenarioId)) {
    return;
  }
  throw firostError(
    'MAKE_SCENARIO_ID_MISSING',
    `Missing --scenarioId, the Scenario ID is named. Usage: ${usage}`,
  );
}
