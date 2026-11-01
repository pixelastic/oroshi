import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { getEventPath } from '../event/getEventPath.js';
import { saveAttendees } from './saveAttendees.js';

export let __;

/**
 * Uninvite one person from an Event. It never notifies them, and keeps the
 * other Attendees
 * @param {object} options - Remove options
 * @param {string} options.eventId - Id of the Event. Throws GCAL_EVENT_ID_MISSING if empty
 * @param {string[]} options.emails - The address to uninvite, only one. Throws GCAL_ATTENDEE_MISSING if empty, and GCAL_ATTENDEE_TOO_MANY for several
 * @param {string} [options.calendarId] - Calendar of the Event, the Primary by default
 * @returns {Promise<object>} The updated Event, formatted by formatEvent
 * @throws {Error} GCAL_ATTENDEE_NOT_FOUND for an address that is not an Attendee, and GCAL_ATTENDEE_ORGANIZER for the organizer. Both fail before any save
 */
export async function attendeeRemove(options) {
  const { eventId, emails, calendarId = 'primary' } = options;
  const eventPath = getEventPath(calendarId, eventId);

  if (_.isEmpty(emails)) {
    throw firostError('GCAL_ATTENDEE_MISSING', 'Pass an e-mail address');
  }
  if (emails.length > 1) {
    throw firostError(
      'GCAL_ATTENDEE_TOO_MANY',
      'Pass one e-mail address, remove them one by one',
    );
  }

  const [email] = emails;
  const current = await __.callApi(eventPath);

  // Addresses are compared without their case
  const target = _.find(
    current.attendees,
    (attendee) => _.toLower(attendee.email) === _.toLower(email),
  );
  // The API does not always list the organizer among the Attendees
  const isOrganizer =
    _.chain(current).get('organizer.email').toLower().value() ===
      _.toLower(email) || _.get(target, 'organizer', false);
  if (isOrganizer) {
    throw firostError(
      'GCAL_ATTENDEE_ORGANIZER',
      `${email} is the organizer of Event ${eventId}`,
    );
  }
  if (!target) {
    throw firostError(
      'GCAL_ATTENDEE_NOT_FOUND',
      `${email} is not an Attendee of Event ${eventId}`,
    );
  }

  return await __.saveAttendees({
    eventId,
    calendarId,
    attendees: _.without(current.attendees, target),
  });
}

__ = {
  callApi,
  saveAttendees,
};
