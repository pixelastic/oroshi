import { _ } from 'golgoth';
import { firostError } from 'firost';
import { saveAttendees } from '../attendee/saveAttendees.js';
import { callApi } from '../callApi.js';
import { getEventPath } from './getEventPath.js';

export let __;

/**
 * Set the Response of Self to an Event. It never notifies the Attendees, and
 * keeps the other Attendees
 * @param {object} options - Respond options
 * @param {string} options.eventId - Id of the Event. Throws GCAL_EVENT_ID_MISSING if empty
 * @param {string} options.responseStatus - The new Response of Self
 * @param {string} [options.calendarId] - Calendar of the Event, the Primary by default
 * @returns {Promise<object>} The updated Event, formatted by formatEvent
 * @throws {Error} GCAL_ATTENDEE_SELF_NOT_FOUND if no Attendee is Self. It fails before any save
 */
export async function eventRespond(options) {
  const { eventId, responseStatus, calendarId = 'primary' } = options;

  const currentEvent = await __.callApi(getEventPath(calendarId, eventId));

  // The API marks the Attendee that is the Account with `self`
  const self = _.find(currentEvent.attendees, { self: true });
  if (!self) {
    throw firostError(
      'GCAL_ATTENDEE_SELF_NOT_FOUND',
      `You are not an Attendee of Event ${eventId}`,
    );
  }

  return await __.saveAttendees({
    eventId,
    calendarId,
    attendees: _.map(currentEvent.attendees, (attendee) =>
      attendee === self ? { ...self, responseStatus } : attendee,
    ),
  });
}

__ = {
  callApi,
  saveAttendees,
};
