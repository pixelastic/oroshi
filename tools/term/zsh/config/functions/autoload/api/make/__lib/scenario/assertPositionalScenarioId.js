import { _ } from 'golgoth';
import { firostError } from 'firost';

/**
 * Throw when the positional Scenario ID is missing
 * @param {number|string} [scenarioId] - Scenario ID, as received by the helper
 * @param {string} usage - Right usage of the helper, shown in the message
 */
export function assertPositionalScenarioId(scenarioId, usage) {
  if (!_.isUndefined(scenarioId)) {
    return;
  }
  throw firostError(
    'MAKE_SCENARIO_ID_MISSING',
    `Missing the Scenario ID, it is positional. Usage: ${usage}`,
  );
}
