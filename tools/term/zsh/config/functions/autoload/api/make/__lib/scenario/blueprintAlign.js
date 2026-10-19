import { _ } from 'golgoth';

// Horizontal gap between two modules, and the single baseline, in the designer
const STEP_X = 300;
const BASELINE_Y = 600;

/**
 * Align the modules of a blueprint on one baseline, left to right
 * @param {object} blueprint - The blueprint to align. It is not changed
 * @returns {object} A copy of the blueprint, with metadata.designer x and y set on every module of its flow
 */
export function blueprintAlign(blueprint) {
  if (!blueprint.flow) {
    return blueprint;
  }
  const flow = _.map(blueprint.flow, (blueprintModule, index) =>
    _.merge({}, blueprintModule, {
      metadata: { designer: { x: STEP_X * index, y: BASELINE_Y } },
    }),
  );
  return { ...blueprint, flow };
}
