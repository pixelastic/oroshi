import { getToday } from './getToday.js';
import { listEvents } from './listEvents.js';
import { resolveDateRange } from './resolveDateRange.js';

export let __;

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
  const { calendarId = 'primary', limit } = options;

  const { dateMin, dateMax } = __.resolveDateRange(options, __.getToday());

  return await __.listEvents({ calendarId, limit, dateMin, dateMax });
}

__ = {
  getToday,
  listEvents,
  resolveDateRange,
};
