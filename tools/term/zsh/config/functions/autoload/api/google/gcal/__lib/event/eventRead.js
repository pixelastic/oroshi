import { callApi } from '../callApi.js';
import { formatEvent } from './formatEvent.js';
import { getEventPath } from './getEventPath.js';

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

  const eventPath = getEventPath(calendarId, eventId);
  const response = await __.callApi(eventPath);
  return __.formatEvent(response, calendarId);
}

__ = {
  callApi,
  formatEvent,
};
