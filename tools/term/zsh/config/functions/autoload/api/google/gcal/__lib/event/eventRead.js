import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { formatEvent } from './formatEvent.js';

export let __;

/**
 * Read one Event
 * @param {object} options - Read options
 * @param {string} options.eventId - Id of the Event. Throws GCAL_EVENT_ID_MISSING if empty
 * @param {string} [options.calendarId] - Calendar of the Event, the Primary by default
 * @returns {Promise<object>} The Event, formatted by formatEvent
 */
export async function eventRead(options) {
  const { eventId, calendarId = 'primary' } = options;

  if (!eventId) {
    throw firostError('GCAL_EVENT_ID_MISSING', 'Pass the id of an Event');
  }

  const response = await __.callApi(
    `calendars/${encodeURIComponent(calendarId)}/events/${encodeURIComponent(eventId)}`,
  );
  return __.formatEvent(response, calendarId);
}

__ = {
  callApi,
  formatEvent,
};
