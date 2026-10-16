import { _, pMap } from 'golgoth';
import { callApi } from '../callApi.js';
import { buildFlow } from '../scenario/buildFlow.js';

export let __;

const PAGE_SIZE = 50;
const CONCURRENCY = 5;

/**
 * Read the flow of a Scenario, with the time each module took in an Execution
 * @param {object} options - Scenario and Execution
 * @param {number|string} options.scenarioId - Scenario ID
 * @param {object} options.execution - The Execution, with its timestamp and duration
 * @returns {Promise<object[]>} The nested flow, each executed module with bundleCount, durationMs and durationPercent
 */
export async function executionTiming(options) {
  const { scenarioId, execution } = options;
  const startMs = Date.parse(execution.timestamp);

  const blueprint = await __.callApi(`scenarios/${scenarioId}/blueprint`);
  const flow = buildFlow(blueprint.response.blueprint.flow);

  // Make only gives timestamps per module, never per Execution, so every
  // module is read, a few at a time to stay under the rate limit
  const moduleIds = __.moduleIds(flow);
  const entries = await pMap(
    moduleIds,
    (moduleId) =>
      __.moduleEntries({
        scenarioId,
        moduleId,
        executionId: execution.id,
        startMs,
      }),
    { concurrency: CONCURRENCY },
  );

  const timings = __.timings({
    entries: _.flatten(entries),
    startMs,
    duration: execution.duration,
  });
  return __.addTimings(flow, timings);
}

__ = {
  /**
   * List the ids of every module of a flow, routes included
   * @param {object[]} flow - The flow, or a route of it
   * @returns {number[]} The module ids
   */
  moduleIds(flow) {
    return _.flatMap(flow, (flowModule) => [
      flowModule.id,
      ..._.flatMap(flowModule.routes, (route) => __.moduleIds(route.flow)),
    ]);
  },
  /**
   * Read the entries of one Execution in the logs of a module. The logs are
   * sorted from the newest, so it reads page after page until one page ends
   * before the Execution started, as nothing older can belong to it
   * @param {object} options - Module and Execution
   * @param {number|string} options.scenarioId - Scenario ID
   * @param {number} options.moduleId - Module ID
   * @param {string} options.executionId - Execution ID
   * @param {number} options.startMs - Start of the Execution, in milliseconds
   * @returns {Promise<object[]>} The entries, as { moduleId, timestampMs, bundles }
   */
  async moduleEntries(options) {
    const { scenarioId, moduleId, executionId, startMs } = options;

    const found = [];
    let offset = 0;
    let isDone = false;
    while (!isDone) {
      const response = await __.callApi(
        `scenarios/${scenarioId}/modules/${moduleId}/logs`,
        { query: { 'pg[limit]': PAGE_SIZE, 'pg[offset]': offset } },
      );
      const page = response.moduleLogs;

      _.each(page, (log) => {
        if (log.executionId !== executionId) {
          return;
        }
        found.push({
          moduleId,
          timestampMs: Date.parse(log.timestamp),
          bundles: log.bundles,
        });
      });

      // A short page is the last one, an old page means nothing more to find
      const oldest = _.last(page);
      const isOld = oldest && Date.parse(oldest.timestamp) < startMs;
      isDone = page.length < PAGE_SIZE || isOld;
      offset += PAGE_SIZE;
    }
    return found;
  },
  /**
   * Sum the time of each module. An entry lasts until the previous entry of
   * the Execution, the first one until the start of the Execution
   * @param {object} options - Entries and Execution times
   * @param {object[]} options.entries - Entries of every module
   * @param {number} options.startMs - Start of the Execution, in milliseconds
   * @param {number} options.duration - Duration of the Execution, in milliseconds
   * @returns {object} The bundleCount, durationMs and durationPercent, by module id
   */
  timings(options) {
    const { entries, startMs, duration } = options;

    const sorted = _.sortBy(entries, 'timestampMs');
    const timings = {};
    _.each(sorted, (entry, index) => {
      const previousMs = index === 0 ? startMs : sorted[index - 1].timestampMs;
      const current = timings[entry.moduleId] || {
        bundleCount: 0,
        durationMs: 0,
      };
      current.bundleCount += entry.bundles;
      current.durationMs += entry.timestampMs - previousMs;
      timings[entry.moduleId] = current;
    });

    return _.mapValues(timings, (timing) => ({
      ...timing,
      durationPercent: Math.round((timing.durationMs / duration) * 100),
    }));
  },
  /**
   * Add the timing of each module to a flow, routes included
   * @param {object[]} flow - The flow, or a route of it
   * @param {object} timings - The timing by module id
   * @returns {object[]} The flow, with the timing of the executed modules
   */
  addTimings(flow, timings) {
    return _.map(flow, (flowModule) => {
      const result = { ...flowModule, ...timings[flowModule.id] };
      if (flowModule.routes) {
        result.routes = _.map(flowModule.routes, (route) => ({
          ...route,
          flow: __.addTimings(route.flow, timings),
        }));
      }
      return result;
    });
  },
  callApi,
};
