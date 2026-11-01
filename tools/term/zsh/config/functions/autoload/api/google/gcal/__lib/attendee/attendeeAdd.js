import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { formatEvent } from '../event/formatEvent.js';
import { saveAttendees } from './saveAttendees.js';

export let __;

/**
 * Invite people to an Event. It never notifies them, and keeps the existing
 * Attendees. An address that is already an Attendee changes nothing
 * @param {object} options - Add options
 * @param {string} options.eventId - Id of the Event. Throws GCAL_EVENT_ID_MISSING if empty
 * @param {string[]} options.emails - Addresses to invite. Throws GCAL_ATTENDEE_MISSING if empty
 * @param {string} [options.calendarId] - Calendar of the Event, the Primary by default
 * @returns {Promise<object>} The Event, formatted by formatEvent
 */
export async function attendeeAdd(options) {
  const { eventId, emails, calendarId = 'primary' } = options;

  if (!eventId) {
    throw firostError('GCAL_EVENT_ID_MISSING', 'Pass the id of an Event');
  }
  if (_.isEmpty(emails)) {
    throw firostError('GCAL_ATTENDEE_MISSING', 'Pass an e-mail address');
  }

  const current = await __.callApi(
    `calendars/${encodeURIComponent(calendarId)}/events/${encodeURIComponent(eventId)}`,
  );

  // Addresses are compared without their case
  const known = _.map(current.attendees, (attendee) =>
    _.toLower(attendee.email),
  );
  const added = _.chain(emails)
    .uniqBy(_.toLower)
    .reject((email) => _.includes(known, _.toLower(email)))
    .map((email) => ({ email }))
    .value();

  if (_.isEmpty(added)) {
    return __.formatEvent(current, calendarId);
  }

  return await __.saveAttendees({
    eventId,
    calendarId,
    attendees: [...(current.attendees ?? []), ...added],
  });
}

__ = {
  callApi,
  formatEvent,
  saveAttendees,
};
