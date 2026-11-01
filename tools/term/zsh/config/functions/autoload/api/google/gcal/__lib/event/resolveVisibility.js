import { firostError } from 'firost';

/**
 * Turn the --private and --public flags into the visibility of the API
 * @param {object} options - Flags of the CLI
 * @param {boolean} [options.isPrivate] - Hide the details of the Event from the readers of the Calendar
 * @param {boolean} [options.isPublic] - Reset the Event to the default visibility of the Calendar
 * @returns {string|undefined} private, default, or undefined when no flag is set
 * @throws {Error} GCAL_VISIBILITY_CONFLICT when both flags are set
 */
export function resolveVisibility(options) {
  const { isPrivate, isPublic } = options;

  if (isPrivate && isPublic) {
    throw firostError(
      'GCAL_VISIBILITY_CONFLICT',
      'Pass either --private or --public, not both',
    );
  }

  if (isPrivate) {
    return 'private';
  }
  if (isPublic) {
    return 'default';
  }
  return undefined;
}
