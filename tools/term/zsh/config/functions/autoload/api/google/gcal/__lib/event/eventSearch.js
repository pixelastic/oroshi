import { _ } from 'golgoth';
import { firostError } from 'firost';
import { getToday } from './getToday.js';
import { listEvents } from './listEvents.js';
import { resolveDateRange } from './resolveDateRange.js';

export let __;

/**
 * Search the Events of a Calendar with a free text, as raw lines, one per
 * Event, sorted by start. It covers the whole Calendar unless a date flag is
 * given
 * @param {object} options - Options of the search
 * @param {string} options.query - Free text the Events must match
 * @param {string} [options.calendarId] - Calendar of the Events, the Primary by default
 * @param {string} [options.dateMin] - First day of the period, as YYYY-MM-DD
 * @param {string} [options.dateMax] - Last day of the period, as YYYY-MM-DD
 * @param {boolean} [options.today] - Period of today only
 * @param {boolean} [options.week] - Period of the current ISO week
 * @param {number} [options.limit] - Maximum number of Events
 * @returns {Promise<string>} Raw lines, joined with a newline
 * @throws {Error} GCAL_QUERY_MISSING when there is no query
 */
export async function eventSearch(options) {
  const { query, calendarId = 'primary', limit } = options;

  if (!query) {
    throw firostError(
      'GCAL_QUERY_MISSING',
      'Give the text to search as the first argument',
    );
  }

  // No default period: the search covers the whole Calendar
  // The bin always sets today and week, to false when absent. The dates stay
  // undefined when absent, and an empty one must still reach the resolver
  const hasDateFlag =
    options.today ||
    options.week ||
    !_.isUndefined(options.dateMin) ||
    !_.isUndefined(options.dateMax);
  const period = hasDateFlag ? __.resolveDateRange(options, __.getToday()) : {};

  return await __.listEvents({ calendarId, limit, query, ...period });
}

__ = {
  getToday,
  listEvents,
  resolveDateRange,
};
