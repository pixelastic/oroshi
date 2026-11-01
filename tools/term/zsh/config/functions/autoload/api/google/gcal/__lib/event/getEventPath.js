import { firostError } from 'firost';
import { getEventsPath } from './getEventsPath.js';

/**
 * Get the API path of one Event
 * @param {string} calendarId - Id of the Calendar
 * @param {string} eventId - Id of the Event. Throws GCAL_EVENT_ID_MISSING if empty
 * @returns {string} The path of the Event
 */
export function getEventPath(calendarId, eventId) {
  if (!eventId) {
    throw firostError('GCAL_EVENT_ID_MISSING', 'Pass the id of an Event');
  }
  return `${getEventsPath(calendarId)}/${encodeURIComponent(eventId)}`;
}
