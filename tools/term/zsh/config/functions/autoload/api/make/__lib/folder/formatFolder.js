/**
 * Format one Folder of the API, to give every command the same output
 * @param {object} response - The Folder, as returned by the API
 * @returns {object} The Folder, as close as possible to the API
 */
export function formatFolder(response) {
  // Identity by default. Tidy only what a real response shows is needed
  return response;
}
