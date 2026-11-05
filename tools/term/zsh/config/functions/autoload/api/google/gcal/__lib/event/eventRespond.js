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
 * @param {string} [options.comment] - The new Comment of Self. Empty clears it, absent keeps it
 * @param {string} [options.calendarId] - Calendar of the Event, the Primary by default
 * @returns {Promise<object>} The updated Event, formatted by formatEvent
 * @throws {Error} GCAL_ATTENDEE_SELF_NOT_FOUND if no Attendee is Self. It fails before any save
 */
export async function eventRespond(options) {
  const { eventId, responseStatus, comment, calendarId = 'primary' } = options;

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
      attendee === self
        ? __.updateSelf(self, { responseStatus, comment })
        : attendee,
    ),
  });
}

__ = {
  /**
   * Set the Response of Self, and its Comment when one is given
   * @param {object} self - The Attendee that is Self
   * @param {object} changes - New values
   * @param {string} changes.responseStatus - The new Response
   * @param {string} [changes.comment] - The new Comment. Empty clears it, undefined keeps it
   * @returns {object} The updated Attendee
   */
  updateSelf(self, { responseStatus, comment }) {
    return _.isUndefined(comment)
      ? { ...self, responseStatus }
      : { ...self, responseStatus, comment };
  },
  callApi,
  saveAttendees,
};
