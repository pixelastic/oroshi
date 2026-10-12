/**
 * Format one Execution of the API, to give every command the same output
 * @param {object} response - The Execution, as returned by the API
 * @returns {object} The Execution, as close as possible to the API
 */
export function formatExecution(response) {
  // Identity by default. Tidy only what a real response shows is needed
  return response;
}
