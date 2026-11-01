import { _ } from 'golgoth';
import { fromApiDates } from './fromApiDates.js';

/**
 * Format one Event of the API into the output JSON shared by every command.
 * The end of an All-day Event is inclusive: the API gives the day after its
 * last day
 * @param {object} response - The Event, as returned by the API
 * @param {string} calendarId - Calendar that holds the Event
 * @returns {object} The Event as { eventId, calendarId, title, status, dateStart, dateEnd, isAllDay, location, description, url, organizer, attendees }. An absent text is an empty string, and organizer is an e-mail address
 */
export function formatEvent(response, calendarId) {
  const { dateStart, dateEnd, isAllDay } = fromApiDates(
    response.start,
    response.end,
  );

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
