import { _ } from 'golgoth';
import { firostError, tmpDirectory, writeJson } from 'firost';
import { getJsonFromOptions } from '@oroshi/api-shared/getJsonFromOptions.js';
import { callApi } from '../callApi.js';
import { blueprintAlign } from './blueprintAlign.js';
import { blueprintValidate } from './blueprintValidate.js';
import { buildFlow } from './buildFlow.js';
import { formatScenario } from './formatScenario.js';
import { scenarioMessages } from './scenarioMessages.js';

export let __;

/**
 * Update some fields of one Scenario. The other fields keep their value.
 * A Blueprint that is sent is validated locally first (see blueprintValidate),
 * and the command stops before any request when it has problems. Then the
 * Blueprint is aligned on one baseline, left to right. Neither step can be
 * skipped.
 * Before it saves a Blueprint, the command writes the current one to a backup
 * file and sends the version it read as baseVersion. When someone else saved
 * the Scenario since, Make answers 409 and the command fails, without
 * overwriting their edit.
 * When Make marks the new Blueprint as invalid, the command sends the backup
 * back and throws MAKE_BLUEPRINT_INVALID with the messages of Make. When that
 * restore fails, the error names the backup file.
 * @param {object} options - Id of the Scenario, and the fields to change
 * @param {number|string} options.scenarioId - Scenario ID
 * @param {string} [options.name] - New name of the Scenario
 * @param {string|object} [options.blueprint] - Blueprint as a JSON string, or the object itself
 * @param {string} [options.blueprintFile] - Path to a JSON file of the Blueprint. Wins over blueprint
 * @param {string|object} [options.scheduling] - Scheduling as a JSON string, or the object itself
 * @param {string} [options.schedulingFile] - Path to a JSON file of the Scheduling. Wins over scheduling
 * @param {number|string} [options.folderId] - Folder ID
 * @returns {Promise<object>} The updated Scenario, formatted, with its flow
 */
export async function scenarioUpdate(options) {
  const { scenarioId, name, folderId } = options;

  const givenBlueprint = await __.getJsonFromOptions(options, 'blueprint');
  const problems = givenBlueprint ? __.blueprintValidate(givenBlueprint) : [];
  if (!_.isEmpty(problems)) {
    throw firostError('MAKE_BLUEPRINT_INVALID', problems.join('\n'));
  }

  // The alignment applies to every Blueprint that is sent, and only to those
  const blueprintContent = givenBlueprint
    ? __.blueprintAlign(givenBlueprint)
    : undefined;
  const schedulingContent = await __.getJsonFromOptions(options, 'scheduling');

  // Read the current Blueprint and its version, so that Make rejects the save
  // (409) if the Scenario changes in between, and so that it can be restored.
  // A save without a Blueprint cannot lose an edit
  const previous = blueprintContent
    ? (await __.callApi(`scenarios/${scenarioId}/blueprint`)).response
    : undefined;
  const backupPath = previous
    ? await __.writeBackup(scenarioId, previous.blueprint)
    : undefined;

  // PATCH leaves the fields that are not given untouched
  const body = _.omitBy(
    {
      name,
      folderId,
      // Make expects the Blueprint and the Scheduling as JSON strings
      // JSON.stringify(undefined) is undefined, so a missing one is not sent
      blueprint: JSON.stringify(blueprintContent),
      scheduling: JSON.stringify(schedulingContent),
      baseVersion: previous?.version,
    },
    _.isUndefined,
  );
  const response = await __.callApi(`scenarios/${scenarioId}`, {
    method: 'PATCH',
    body,
  });

  if (blueprintContent && response.scenario.isinvalid) {
    throw await __.restore(scenarioId, previous.blueprint, backupPath);
  }

  // Use the Blueprint that was sent to avoid a second call. Without one, read
  // it like scenarioRead does
  const flow = blueprintContent
    ? blueprintContent.flow
    : (await __.callApi(`scenarios/${scenarioId}/blueprint`)).response.blueprint
        .flow;

  return {
    ...__.formatScenario(response.scenario),
    flow: __.buildFlow(flow),
  };
}

__ = {
  /**
   * Write the Blueprint to a backup file in a temporary directory
   * @param {number|string} scenarioId - Scenario ID
   * @param {object} blueprint - The Blueprint to keep
   * @returns {Promise<string>} Path of the backup file
   */
  async writeBackup(scenarioId, blueprint) {
    const backupPath = `${__.tmpDirectory('make-scenario-update')}/${scenarioId}.json`;
    await __.writeJson(blueprint, backupPath);
    return backupPath;
  },
  /**
   * Send the backup back as the Blueprint of the Scenario
   * @param {number|string} scenarioId - Scenario ID
   * @param {object} blueprint - The previous Blueprint
   * @param {string} backupPath - Path of the backup file
   * @returns {Promise<Error>} The error to throw: invalid, or restore failed
   */
  async restore(scenarioId, blueprint, backupPath) {
    const messages = await __.scenarioMessages(scenarioId);
    try {
      await __.callApi(`scenarios/${scenarioId}`, {
        method: 'PATCH',
        body: { blueprint: JSON.stringify(blueprint) },
      });
    } catch (error) {
      return firostError(
        'MAKE_BLUEPRINT_RESTORE_FAILED',
        [
          `Make marked the new Blueprint as invalid, and the restore failed: ${error.message}`,
          `The previous Blueprint is in ${backupPath}`,
          ...messages,
        ].join('\n'),
      );
    }
    return firostError(
      'MAKE_BLUEPRINT_INVALID',
      [
        'Make marked the new Blueprint as invalid, the previous one is restored',
        ...messages,
      ].join('\n'),
    );
  },
  callApi,
  getJsonFromOptions,
  blueprintAlign,
  blueprintValidate,
  buildFlow,
  formatScenario,
  scenarioMessages,
  tmpDirectory,
  writeJson,
};
