import { _ } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { callApi } from '../callApi.js';
import { formatCalendar } from './formatCalendar.js';

export let __;

// Largest page that calendarList.list accepts
const MAX_PAGE_SIZE = 250;
const DEFAULT_LIMIT = 25;

/**
 * List the Calendars as raw lines, one per Calendar. The Primary comes first,
 * then the others by name
 * @param {object} options - Options of the listing
 * @param {number} [options.limit] - Maximum number of Calendars
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function calendarListRaw(options) {
  const { limit = DEFAULT_LIMIT } = options;

  // The order of the API is not guaranteed, so every page is needed to find
  // the Primary before the limit applies
  const calendars = await __.getAllCalendars();

  return _.chain(calendars)
    .map(formatCalendar)
    .orderBy(
      [
        (calendar) => !calendar.primary,
        (calendar) => _.toLower(__.getName(calendar)),
      ],
      ['asc', 'asc'],
    )
    .take(limit)
    .map(__.toLine)
    .join('\n')
    .value();
}

__ = {
  /**
   * Get the Calendars of every page of calendarList.list
   * @returns {Promise<object[]>} The Calendar list entries
   */
  async getAllCalendars() {
    const calendars = [];
    let pageToken = null;
    do {
      const response = await __.callApi('users/me/calendarList', {
        query: { maxResults: MAX_PAGE_SIZE, pageToken },
      });
      calendars.push(..._.get(response, 'items', []));
      pageToken = response.nextPageToken;
    } while (pageToken);
    return calendars;
  },

  /**
   * Get the name of a Calendar, as the user renamed it if they did
   * @param {object} calendar - Calendar list entry
   * @returns {string} The name of the Calendar
   */
  getName(calendar) {
    return calendar.summaryOverride || calendar.summary;
  },

  /**
   * Turn one Calendar into a raw line
   * @param {object} calendar - Formatted Calendar
   * @returns {string} The Calendar fields, separated by ▮
   */
  toLine(calendar) {
    return _.chain([
      calendar.id,
      __.getName(calendar),
      Boolean(calendar.primary),
      calendar.timeZone,
    ])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },

  callApi,
};
