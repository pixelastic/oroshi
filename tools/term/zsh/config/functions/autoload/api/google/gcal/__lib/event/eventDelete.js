import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { getEventPath } from './getEventPath.js';

export let __;

/**
 * Delete one Event. It never notifies the Attendees
 * @param {object} options - Delete options
 * @param {string} options.eventId - Id of the Event. Throws GCAL_EVENT_ID_MISSING if empty
 * @param {string} [options.calendarId] - Calendar of the Event, the Primary by default
 * @returns {Promise<string>} The id of the deleted Event
 * @throws {Error} GCAL_EVENT_NOT_FOUND if the Event does not exist, or is already deleted
 */
export async function eventDelete(options) {
  const { eventId, calendarId = 'primary' } = options;

  const eventPath = getEventPath(calendarId, eventId);
  try {
    await __.callApi(eventPath, {
      method: 'DELETE',
      query: { sendUpdates: 'none' },
    });
  } catch (error) {
    // callApi starts the message of a failed request with the HTTP status. The
    // API answers 410 for an Event that is already deleted
    const isNotFound =
      error.code === 'GCAL_REQUEST_FAILED' &&
      /^(404|410)\b/.test(error.message);
    if (isNotFound) {
      throw firostError('GCAL_EVENT_NOT_FOUND', `Event ${eventId} not found`);
    }
    throw error;
  }

  return eventId;
}

__ = {
  callApi,
};
