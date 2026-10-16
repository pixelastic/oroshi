import { assertScenarioId } from '../assertScenarioId.js';

describe('assertScenarioId', () => {
  it.each([{ input: 925 }, { input: '925' }, { input: 0 }])(
    'does nothing with the Scenario ID $input',
    ({ input }) => {
      expect(() => assertScenarioId(input, 'make-thing')).not.toThrow();
    },
  );

  it('throws MAKE_SCENARIO_ID_MISSING with the usage', () => {
    let actual = null;
    try {
      assertScenarioId(undefined, 'make-thing <scenarioId>');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'MAKE_SCENARIO_ID_MISSING');
    expect(actual).toHaveProperty(
      'message',
      'Missing the Scenario ID. Usage: make-thing <scenarioId>',
    );
  });
});
