/**
 * Get the API path of the Events of a Calendar
 * @param {string} calendarId - Id of the Calendar
 * @returns {string} The path of the Events collection
 */
export function getEventsPath(calendarId) {
  return `calendars/${encodeURIComponent(calendarId)}/events`;
}
