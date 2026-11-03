/**
 * Format one Page of the API, to give every command the same output
 * @param {object} response - The Page, as returned by the API
 * @returns {object} The Page, as close as possible to the API
 */
export function formatPage(response) {
  // Identity by default. Tidy only what a real response shows is needed
  return response;
}
