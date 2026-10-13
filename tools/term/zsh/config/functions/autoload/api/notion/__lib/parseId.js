import { firostError } from 'firost';

const ID_PATTERN =
  /[0-9a-f]{8}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{12}/gi;

/**
 * Get the bare dashed id from a Notion URL or an id
 * @param {string} input - A Notion URL, or an id with or without dashes
 * @returns {string} The id, with dashes
 */
export function parseId(input = '') {
  // In a URL, the id is in `p` for a preview, and in the path otherwise. The
  // `v` view id of a Database never matters
  let candidate = input;
  if (URL.canParse(input)) {
    const url = new URL(input);
    candidate = url.searchParams.get('p') || url.pathname;
  }

  // A title slug comes before the id, so the id is the last match
  const matches = candidate.match(ID_PATTERN);
  if (!matches) {
    throw firostError('NOTION_ID_INVALID', `No Notion id found in "${input}"`);
  }

  const bare = matches.at(-1).replaceAll('-', '');
  return [
    bare.slice(0, 8),
    bare.slice(8, 12),
    bare.slice(12, 16),
    bare.slice(16, 20),
    bare.slice(20),
  ].join('-');
}
