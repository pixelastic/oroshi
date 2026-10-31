import { _, dayjs } from 'golgoth';

const DATE_FORMAT = 'YYYY-MM-DD';

/**
 * Format one Event of the API, to give every command the same output. It adds
 * isAllDay, and makes the end of an All-day Event inclusive: the API gives the
 * day after its last day
 * @param {object} response - The Event, as returned by the API
 * @returns {object} The Event, as close as possible to the API
 */
export function formatEvent(response) {
  const isAllDay = _.has(response, 'start.date');
  if (!isAllDay) {
    return { ...response, isAllDay };
  }

  const lastDay = dayjs(response.end.date).subtract(1, 'day');
  return {
    ...response,
    isAllDay,
    end: { ...response.end, date: lastDay.format(DATE_FORMAT) },
  };
}
