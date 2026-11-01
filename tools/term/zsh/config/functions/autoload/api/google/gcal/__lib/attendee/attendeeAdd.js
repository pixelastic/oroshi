import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { formatEvent } from '../event/formatEvent.js';
import { getEventPath } from '../event/getEventPath.js';
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
  const eventPath = getEventPath(calendarId, eventId);

  if (_.isEmpty(emails)) {
    throw firostError('GCAL_ATTENDEE_MISSING', 'Pass an e-mail address');
  }

  const currentEvent = await __.callApi(eventPath);

  // Addresses are compared without their case
  const known = _.map(currentEvent.attendees, (attendee) =>
    _.toLower(attendee.email),
  );
  const added = _.chain(emails)
    .uniqBy(_.toLower)
    .reject((email) => _.includes(known, _.toLower(email)))
    .map((email) => ({ email }))
    .value();

  if (_.isEmpty(added)) {
    return __.formatEvent(currentEvent, calendarId);
  }

  return await __.saveAttendees({
    eventId,
    calendarId,
    attendees: [...(currentEvent.attendees ?? []), ...added],
  });
}

__ = {
  callApi,
  formatEvent,
  saveAttendees,
};
