import { callApi } from '../callApi.js';

export let __;

/**
 * Get the time zone of a Calendar
 * @param {string} calendarId - Id of the Calendar
 * @returns {Promise<string>} The time zone, as an IANA name
 */
export async function getTimeZone(calendarId) {
  const calendar = await __.callApi(
    `users/me/calendarList/${encodeURIComponent(calendarId)}`,
  );
  return calendar.timeZone;
}

__ = {
  callApi,
};
