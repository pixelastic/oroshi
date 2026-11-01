import { _, dayjs } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { callApi } from '../callApi.js';
import { formatEvent } from './formatEvent.js';
import { getEventsPath } from './getEventsPath.js';

export let __;

// Largest page that events.list accepts
const MAX_PAGE_SIZE = 250;
const DEFAULT_LIMIT = 25;

/**
 * List the Events of a Calendar as raw lines, one per Event, sorted by start.
 * Recurring Events are expanded into one Event per occurrence
 * @param {object} options - Options of the listing
 * @param {string} options.calendarId - Calendar of the Events
 * @param {string} [options.query] - Free text the Events must match
 * @param {string} [options.dateMin] - First day of the period, as YYYY-MM-DD
 * @param {string} [options.dateMax] - Last day of the period, as YYYY-MM-DD
 * @param {number} [options.limit] - Maximum number of Events
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function listEvents(options) {
  const {
    calendarId,
    query,
    dateMin,
    dateMax,
    limit = DEFAULT_LIMIT,
  } = options;

  // The API compares times, so the period runs from the start of the first day
  // to the start of the day after the last one
  const events = await __.getEvents(calendarId, limit, {
    q: query,
    timeMin: dateMin && dayjs(dateMin).startOf('day').format(),
    timeMax: dateMax && dayjs(dateMax).add(1, 'day').startOf('day').format(),
  });

  return _.chain(events)
    .map((event) => formatEvent(event, calendarId))
    .map(__.toLine)
    .join('\n')
    .value();
}

__ = {
  /**
   * Get the Events matching a filter, in the order of the API (by start),
   * reading pages until the limit is reached
   * @param {string} calendarId - Calendar of the Events
   * @param {number} limit - Maximum number of Events
   * @param {object} filter - Filter of the Events, each key is optional
   * @param {string} [filter.q] - Free text the Events must match
   * @param {string} [filter.timeMin] - Start of the period, as RFC3339
   * @param {string} [filter.timeMax] - End of the period, as RFC3339
   * @returns {Promise<object[]>} The Events, as returned by the API
   */
  async getEvents(calendarId, limit, { q, timeMin, timeMax }) {
    const path = getEventsPath(calendarId);
    const events = [];
    let pageToken = null;
    do {
      const response = await __.callApi(path, {
        query: {
          q,
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
};
