import { _, dayjs } from 'golgoth';
import { DATE_FORMAT } from './dateFormats.js';

/**
 * Convert the start and end of the API into the dates of the CLI
 * The end of an All-day Event is inclusive: the API gives the day after its
 * last day
 * @param {object} start - Start of the API, as { dateTime } or { date }
 * @param {object} end - End of the API, in the same format as the start
 * @returns {{dateStart: string, dateEnd: string, isAllDay: boolean}} The dates, and whether the Event is an All-day Event
 */
export function fromApiDates(start, end) {
  const isAllDay = _.has(start, 'date');

  return {
    dateStart: isAllDay ? start.date : start.dateTime,
    dateEnd: isAllDay
      ? dayjs.utc(end.date).subtract(1, 'day').format(DATE_FORMAT)
      : end.dateTime,
    isAllDay,
  };
}
