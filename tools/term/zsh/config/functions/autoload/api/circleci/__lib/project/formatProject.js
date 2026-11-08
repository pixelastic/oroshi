/**
 * Format one Project of the API, to give every command the same output
 * @param {object} response - The Project, as returned by the API
 * @returns {object} The Project, as close as possible to the API
 */
export function formatProject(response) {
  // Identity by default. Tidy only what a real response shows is needed
  return response;
}
