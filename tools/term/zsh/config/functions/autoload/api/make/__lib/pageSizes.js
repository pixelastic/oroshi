/**
 * The most items the API returns in one page, for each entity. Checked against
 * the live API: executions refuse more than 50 (SC400), scenarios accept at
 * least 10 000
 */
export const pageSizes = {
  execution: 50,
  scenario: 10000,
};
