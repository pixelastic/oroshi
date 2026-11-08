import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { formatProject } from './formatProject.js';

export let __;

/**
 * Read one Project of CircleCI
 * @param {object} options - Slug of the Project
 * @param {string} options.projectSlug - Slug of the Project (gh/<org>/<repo>)
 * @returns {Promise<object>} The Project, formatted
 */
export async function projectRead(options) {
  const { projectSlug } = options;

  if (!projectSlug) {
    throw firostError(
      'CIRCLECI_MISSING_ARGUMENT',
      'Pass the slug of the project (gh/<org>/<repo>)',
    );
  }

  const response = await __.callApi(`project/${projectSlug}`);
  return __.formatProject(response);
}

__ = {
  callApi,
  formatProject,
};
