/**
 * Format one Scenario of the API, to give every command the same output
 * @param {object} response - The Scenario, as returned by the API
 * @returns {object} The Scenario, as close as possible to the API
 */
export function formatScenario(response) {
  // Identity by default. Tidy only what a real response shows is needed
  return response;
}
