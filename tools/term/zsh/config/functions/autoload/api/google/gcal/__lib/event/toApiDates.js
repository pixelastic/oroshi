import { _, dayjs } from 'golgoth';
import { firostError } from 'firost';
import { API_TIME_FORMAT, DATE_FORMAT, TIME_FORMAT } from './dateFormats.js';

export let __;

/**
 * Convert the dates of the CLI into the start and end of the API
 * A date with a time is local to the Calendar. A date without a time is an
 * All-day Event, whose end is inclusive for the user and exclusive for the API
 * @param {object} options - Dates to convert
 * @param {string} options.dateStart - Start, as YYYY-MM-DDTHH:MM or YYYY-MM-DD
 * @param {string} [options.dateEnd] - End, in the same format as the start. One hour (or one day) after the start by default
 * @param {string} options.timeZone - Time zone of the Calendar, as an IANA name
 * @returns {{start: object, end: object}} The start and end of the API, as { dateTime, timeZone } or { date }
 * @throws {Error} GCAL_DATE_START_MISSING without a start, GCAL_DATE_INVALID on a date that is not a real YYYY-MM-DDTHH:MM or YYYY-MM-DD (an offset included) or on mixed formats, GCAL_DATE_RANGE_INVALID when the end is before the start
 */
export function toApiDates(options) {
  const { dateStart, dateEnd, timeZone } = options;

  if (_.isUndefined(dateStart)) {
    throw firostError(
      'GCAL_DATE_START_MISSING',
      'Pass the start with --date-start',
    );
  }

  const start = __.parseDate(dateStart, '--date-start');
  const end = _.isUndefined(dateEnd)
    ? null
    : __.parseDate(dateEnd, '--date-end');

  if (end && end.isAllDay !== start.isAllDay) {
    throw firostError(
      'GCAL_DATE_INVALID',
      `--date-start ${dateStart} and --date-end ${dateEnd} must both have a time, or both have none`,
    );
  }
  if (end && start.date.isAfter(end.date)) {
    throw firostError(
      'GCAL_DATE_RANGE_INVALID',
      `--date-end ${dateEnd} is before --date-start ${dateStart}`,
    );
  }

  if (start.isAllDay) {
    const last = end ? end.date : start.date;
    return {
      start: { date: start.date.format(DATE_FORMAT) },
      end: { date: last.add(1, 'day').format(DATE_FORMAT) },
    };
  }

  // The times are added on the clock, so that a change of time does not move
  // the default end
  const finish = end ? end.date : start.date.add(1, 'hour');
  return {
    start: { dateTime: start.date.format(API_TIME_FORMAT), timeZone },
    end: { dateTime: finish.format(API_TIME_FORMAT), timeZone },
  };
}

__ = {
  /**
   * Parse a date given to a flag. It is read as UTC, to keep the clock of the
   * user whatever the time zone of the machine
   * @param {string} value - The date, as YYYY-MM-DDTHH:MM or YYYY-MM-DD
   * @param {string} flag - Name of the flag, for the error message
   * @returns {{date: import('dayjs').Dayjs, isAllDay: boolean}} The date, and whether it has no time
   * @throws {Error} GCAL_DATE_INVALID when the value is not a real date in one of the two formats
   */
  parseDate(value, flag) {
    const isAllDay = _.size(value) === DATE_FORMAT.length;
    const format = isAllDay ? DATE_FORMAT : TIME_FORMAT;
    const date = dayjs.utc(value);
    // A date that dayjs rolls over (2026-02-30), reads loosely (02/11/2026) or
    // reads with an offset does not round-trip
    if (date.format(format) !== value) {
      throw firostError(
        'GCAL_DATE_INVALID',
        `${flag} "${value}" is not a date, use YYYY-MM-DDTHH:MM (local time, no offset) or YYYY-MM-DD`,
      );
    }
    return { date, isAllDay };
  },
};
