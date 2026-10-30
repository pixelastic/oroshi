/**
 * Format one Calendar of the API, to give every command the same output
 * @param {object} response - The Calendar, as returned by the API
 * @returns {object} The Calendar, as close as possible to the API
 */
export function formatCalendar(response) {
  // Identity by default. Tidy only what a real response shows is needed
  return response;
}
