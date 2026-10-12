import { formatExecution } from '../formatExecution.js';

describe('formatExecution', () => {
  it('returns the Execution as the API gives it', () => {
    const execution = { id: 'cfcf', status: 3, type: 'auto' };

    const actual = formatExecution(execution);

    expect(actual).toEqual(execution);
  });
});
