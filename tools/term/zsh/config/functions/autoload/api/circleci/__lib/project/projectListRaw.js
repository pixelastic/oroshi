import { _ } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { projectSearch } from './projectSearch.js';

export let __;

/**
 * List the Projects as raw lines, one per Project
 * @param {object} options - Same options as search
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function projectListRaw(options) {
  // Ask search for the Projects, with the flags we received
  const projects = await __.projectSearch(options);

  return _.chain(projects).map(__.toLine).join('\n').value();
}

__ = {
  /**
   * Turn one Project into a raw line
   * @param {object} project - Project, as returned by search
   * @returns {string} The slug and the default branch, separated by ▮
   */
  toLine(project) {
    const { slug, vcs_info } = project;
    return _.chain([slug, vcs_info?.default_branch])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },
  projectSearch,
};
