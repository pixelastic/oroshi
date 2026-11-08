import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { defaultLimit } from '../defaultLimit.js';
import { formatProject } from './formatProject.js';

export let __;

const V1_BASE_URL = 'https://circleci.com/api/v1.1';
const SLUG_PREFIXES = { github: 'gh', bitbucket: 'bb' };

/**
 * Search the Projects that the account follows
 * @param {object} options - The query and the limit
 * @param {string} [options.query] - Text to look for in the slug, ignoring case
 * @param {number|string} [options.limit] - Maximum number of Projects
 * @returns {Promise<object[]>} The Projects, formatted
 */
export async function projectSearch(options) {
  const { query = '', limit = defaultLimit } = options;

  // Validate before calling the API, so a typo costs no request
  const max = __.toLimit(limit);

  // The v2 API has no list of Projects. The v1.1 list is not paginated, and
  // holds only the Projects that the account follows
  const response = await __.callApi('projects', { baseUrl: V1_BASE_URL });

  return _.chain(response)
    .map(__.toProject)
    .filter(({ slug }) =>
      _.chain(slug).toLower().includes(_.toLower(query)).value(),
    )
    .take(max)
    .map(__.formatProject)
    .value();
}

__ = {
  /**
   * Convert the limit to a positive integer
   * @param {number|string} limit - The limit, as a number or as typed in a flag
   * @returns {number} The limit
   */
  toLimit(limit) {
    const value =
      _.isString(limit) && limit.trim() === '' ? NaN : Number(limit);
    if (!Number.isInteger(value) || value < 1) {
      throw firostError(
        'CIRCLECI_INVALID_ARGUMENT',
        `--limit must be a positive integer, got "${limit}"`,
      );
    }
    return value;
  },
  /**
   * Turn one Project of the v1.1 API into the shape of the v2 API
   * @param {object} project - The Project, as returned by v1.1
   * @returns {object} The Project, with its slug
   */
  toProject(project) {
    const { username, reponame, vcs_type, vcs_url, default_branch } = project;
    const prefix = SLUG_PREFIXES[vcs_type] ?? vcs_type;
    return {
      slug: `${prefix}/${username}/${reponame}`,
      name: reponame,
      vcs_info: { vcs_url, default_branch },
    };
  },
  callApi,
  formatProject,
};
