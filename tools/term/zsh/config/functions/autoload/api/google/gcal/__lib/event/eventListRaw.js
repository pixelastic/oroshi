import { _, dayjs } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { callApi } from '../callApi.js';
import { formatEvent } from './formatEvent.js';
import { resolveDateRange } from './resolveDateRange.js';

export let __;

// Largest page that events.list accepts
const MAX_PAGE_SIZE = 250;
const DEFAULT_LIMIT = 25;
const DATE_FORMAT = 'YYYY-MM-DD';

/**
 * List the Events of a period as raw lines, one per Event, sorted by start.
 * Recurring Events are expanded into one Event per occurrence
 * @param {object} options - Options of the listing
 * @param {string} [options.calendarId] - Calendar of the Events, the Primary by default
 * @param {string} [options.dateMin] - First day of the period, as YYYY-MM-DD
 * @param {string} [options.dateMax] - Last day of the period, as YYYY-MM-DD
 * @param {boolean} [options.today] - Period of today only
 * @param {boolean} [options.week] - Period of the current ISO week
 * @param {number} [options.limit] - Maximum number of Events
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function eventListRaw(options) {
  const { calendarId = 'primary', limit = DEFAULT_LIMIT } = options;

  const { dateMin, dateMax } = __.resolveDateRange(options, __.getToday());

  // The API compares times, so the period runs from the start of the first day
  // to the start of the day after the last one
  const events = await __.getEvents(calendarId, limit, {
    timeMin: dayjs(dateMin).startOf('day').format(),
    timeMax: dayjs(dateMax).add(1, 'day').startOf('day').format(),
  });

  return _.chain(events)
    .map((event) => __.formatEvent(event, calendarId))
    .map(__.toLine)
    .join('\n')
    .value();
}

__ = {
  /**
   * Get the date of today
   * @returns {string} Today, as YYYY-MM-DD
   */
  getToday() {
    return dayjs().format(DATE_FORMAT);
  },

  /**
   * Get the Events of a period, in the order of the API (by start), reading
   * pages until the limit is reached
   * @param {string} calendarId - Calendar of the Events
   * @param {number} limit - Maximum number of Events
   * @param {object} period - Period of the Events
   * @param {string} period.timeMin - Start of the period, as RFC3339
   * @param {string} period.timeMax - End of the period, as RFC3339
   * @returns {Promise<object[]>} The Events, as returned by the API
   */
  async getEvents(calendarId, limit, { timeMin, timeMax }) {
    const path = `calendars/${encodeURIComponent(calendarId)}/events`;
    const events = [];
    let pageToken = null;
    do {
      const response = await __.callApi(path, {
        query: {
          timeMin,
          timeMax,
          singleEvents: true,
          orderBy: 'startTime',
          maxResults: Math.min(limit - events.length, MAX_PAGE_SIZE),
          pageToken,
        },
      });
      events.push(..._.get(response, 'items', []));
      pageToken = response.nextPageToken;
    } while (pageToken && events.length < limit);
    return _.take(events, limit);
  },

  /**
   * Turn one Event into a raw line
   * @param {object} event - Formatted Event
   * @returns {string} The Event fields, separated by ▮
   */
  toLine(event) {
    return _.chain([
      event.eventId,
      event.title,
      event.status,
      event.dateStart,
      event.dateEnd,
      event.isAllDay,
      _.size(event.attendees),
      event.location,
    ])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },

  callApi,
  formatEvent,
  resolveDateRange,
};
