import { _ } from 'golgoth';
import { firostError } from 'firost';

/**
 * Extract the listing URL from the output of vinted-listing-create
 * The URL is in the JSON of the last non-empty line.
 * @param {string} output - Output of the post helper
 * @returns {string} URL of the published listing
 */
export function parsePostedUrl(output) {
  const lastLine = _.chain(output)
    .split('\n')
    .map(_.trim)
    .compact()
    .last()
    .value();

  let url = null;
  try {
    url = JSON.parse(lastLine)?.url;
  } catch {
    // A last line that is not JSON means nothing was published
  }

  if (!_.isString(url) || url === '') {
    throw firostError(
      'VINTED_LISTING_URL_NOT_FOUND',
      'The last output line holds no listing URL',
    );
  }
  return url;
}
