import { callApi } from '../callApi.js';
import { formatEvent } from '../event/formatEvent.js';

export let __;

/**
 * Replace the Attendees of an Event. It never notifies anyone
 * @param {object} options - Save options
 * @param {string} options.eventId - Id of the Event
 * @param {string} options.calendarId - Calendar of the Event
 * @param {object[]} options.attendees - The whole new list of Attendees, as the API expects it
 * @returns {Promise<object>} The updated Event, formatted by formatEvent
 */
export async function saveAttendees(options) {
  const { eventId, calendarId, attendees } = options;

  const response = await __.callApi(
    `calendars/${encodeURIComponent(calendarId)}/events/${encodeURIComponent(eventId)}`,
    {
      method: 'PATCH',
      query: { sendUpdates: 'none' },
      body: { attendees },
    },
  );
  return __.formatEvent(response, calendarId);
}

__ = {
  callApi,
  formatEvent,
};
