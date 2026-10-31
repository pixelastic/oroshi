import { _, dayjs } from 'golgoth';

const DATE_FORMAT = 'YYYY-MM-DD';

/**
 * Format one Event of the API into the output JSON shared by every command.
 * The end of an All-day Event is inclusive: the API gives the day after its
 * last day
 * @param {object} response - The Event, as returned by the API
 * @param {string} calendarId - Calendar that holds the Event
 * @returns {object} The Event as { eventId, calendarId, title, status, dateStart, dateEnd, isAllDay, location, description, url, organizer, attendees }. An absent text is an empty string, and organizer is an e-mail address
 */
export function formatEvent(response, calendarId) {
  const isAllDay = _.has(response, 'start.date');
  const dateStart = response.start.dateTime || response.start.date;
  const dateEnd = isAllDay
    ? dayjs(response.end.date).subtract(1, 'day').format(DATE_FORMAT)
    : response.end.dateTime;

  return {
    eventId: response.id,
    calendarId,
    title: _.get(response, 'summary', ''),
    status: response.status,
    dateStart,
    dateEnd,
    isAllDay,
    location: _.get(response, 'location', ''),
    description: _.get(response, 'description', ''),
    url: response.htmlLink,
    organizer: _.get(response, 'organizer.email', ''),
    attendees: _.map(response.attendees, (attendee) =>
      _.pick(attendee, ['email', 'responseStatus']),
    ),
  };
}
