import { _ } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { runSearch } from './runSearch.js';

export let __;

/**
 * List the Runs of a Project as raw lines, one per Run
 * @param {object} options - Same options as search
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function runListRaw(options) {
  // Ask search for the Runs, with the flags we received
  const runs = await __.runSearch(options);

  return _.chain(runs).map(__.toLine).join('\n').value();
}

__ = {
  /**
   * Turn one Run into a raw line
   * @param {object} run - Run, as returned by search
   * @returns {string} The id, project, name, status, branch, commit, pipeline number, creation date, duration and URL, separated by ▮
   */
  toLine(run) {
    const {
      id,
      project,
      name,
      status,
      branch,
      commit,
      pipelineNumber,
      createdAt,
      duration,
      url,
    } = run;
    return _.chain([
      id,
      project,
      name,
      status,
      branch,
      commit,
      pipelineNumber,
      createdAt,
      duration,
      url,
    ])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },
  runSearch,
};
