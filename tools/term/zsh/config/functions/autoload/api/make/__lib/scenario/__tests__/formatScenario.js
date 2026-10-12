import { formatScenario } from '../formatScenario.js';

describe('formatScenario', () => {
  it('returns the scenario as the API gives it', () => {
    const scenario = { id: 925, name: 'New scenario', isActive: false };

    const actual = formatScenario(scenario);

    expect(actual).toEqual(scenario);
  });
});
