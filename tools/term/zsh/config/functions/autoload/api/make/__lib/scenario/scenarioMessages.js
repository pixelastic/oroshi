import { _ } from 'golgoth';
import { callApi } from '../callApi.js';

export let __;

/**
 * Read the validation messages that Make attached to the Blueprint of a Scenario
 * @param {number|string} scenarioId - Scenario ID
 * @returns {Promise<string[]>} The messages, empty when Make gave none
 */
export async function scenarioMessages(scenarioId) {
  const { response } = await __.callApi(`scenarios/${scenarioId}/blueprint`);
  const messages = _.get(response, 'blueprint.metadata.designer.messages', []);
  return _.map(messages, (message) =>
    _.isString(message) ? message : JSON.stringify(message),
  );
}

__ = {
  callApi,
};
