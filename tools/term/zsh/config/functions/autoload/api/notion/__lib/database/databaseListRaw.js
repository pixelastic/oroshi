import { _ } from 'golgoth';
import { firostError } from 'firost';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { callApi } from '../callApi.js';
import { parseId } from '../parseId.js';
import { resolveDataSource } from './resolveDataSource.js';

export let __;

const DEFAULT_LIMIT = 25;
const MAX_PAGE_SIZE = 100;

/**
 * List the rows of a Database as raw lines, one per row. A line holds the
 * row ID, then its title. It makes one API call per page of rows, and follows
 * the cursor until the limit is reached or the API has no more rows
 * @param {object} options - List options
 * @param {string} options.databaseId - ID or URL of the Database. Throws NOTION_ID_INVALID if it holds no id
 * @param {string} [options.filter] - Notion filter, as JSON. Throws NOTION_JSON_INVALID if it is not valid JSON
 * @param {string} [options.sort] - Notion sorts, as JSON. Throws NOTION_JSON_INVALID if it is not valid JSON
 * @param {number} [options.limit] - Maximum number of rows
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function databaseListRaw(options) {
  const { limit = DEFAULT_LIMIT } = options;
  const databaseId = __.parseId(options.databaseId);
  const filter = __.parseJson(options.filter, 'filter');
  const sorts = __.parseJson(options.sort, 'sort');

  const database = await __.callApi(`databases/${databaseId}`);
  const dataSource = await __.resolveDataSource(database);

  const rows = [];
  let cursor;
  do {
    const response = await __.callApi(`data_sources/${dataSource.id}/query`, {
      method: 'POST',
      body: {
        filter,
        sorts,
        page_size: Math.min(limit - rows.length, MAX_PAGE_SIZE),
        start_cursor: cursor,
      },
    });
    rows.push(...response.results);
    cursor = response.has_more ? response.next_cursor : null;
  } while (cursor && rows.length < limit);

  return _.chain(rows)
    .map((row) => __.toLine(row))
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one row into a raw line
   * @param {object} row - The row, as returned by the API
   * @returns {string} The row ID and its title, separated by ▮
   */
  toLine(row) {
    // The title is the one property of type title, whatever its name
    const titleProperty = _.find(row.properties, { type: 'title' });
    const title = _.chain(titleProperty?.title)
      .map('plain_text')
      .join('')
      .value();

    return _.chain([row.id, title])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },
  /**
   * Parse a JSON flag
   * @param {string} [value] - The flag value
   * @param {string} name - The flag name, for the error message
   * @returns {object|undefined} The parsed value, undefined if the flag is not set
   */
  parseJson(value, name) {
    if (_.isUndefined(value)) {
      return undefined;
    }
    try {
      return JSON.parse(value);
    } catch (error) {
      throw firostError(
        'NOTION_JSON_INVALID',
        `--${name} is not valid JSON: ${error.message}`,
      );
    }
  },
  callApi,
  parseId,
  resolveDataSource,
};
