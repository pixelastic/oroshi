import { _ } from 'golgoth';

// Gap between two modules, horizontally and vertically, and the main baseline
const STEP_X = 300;
const STEP_Y = 300;
const BASELINE_Y = 600;

export let __;

/**
 * Align the modules of a blueprint on a grid: the flow on one baseline,
 * routes stacked around their router, error handlers under their module and
 * orphans in a row under everything else
 * @param {object} blueprint - The blueprint to align. It is not changed
 * @returns {object} A copy of the blueprint, with metadata.designer x and y set on every module
 */
export function blueprintAlign(blueprint) {
  if (!blueprint.flow) {
    return blueprint;
  }
  const flow = __.alignFlow(blueprint.flow, 0, BASELINE_Y);

  const orphans = blueprint.metadata?.designer?.orphans;
  if (_.isEmpty(orphans)) {
    return { ...blueprint, flow };
  }

  const orphansY =
    _.chain(__.listModules(flow)).map(__.getY).max().value() + STEP_Y;
  return _.merge({}, blueprint, {
    flow,
    metadata: { designer: { orphans: __.alignFlow(orphans, 0, orphansY) } },
  });
}

__ = {
  /**
   * Place modules one after the other, to the right of a starting point
   * @param {object[]} flow - Modules to place
   * @param {number} x - Position of the first module
   * @param {number} y - Baseline of the modules
   * @returns {object[]} Copies of the modules, positioned
   */
  alignFlow(flow, x, y) {
    return _.map(flow, (blueprintModule, index) =>
      __.alignModule(blueprintModule, x + STEP_X * index, y),
    );
  },

  /**
   * Place one module, its routes and its error handler
   * @param {object} blueprintModule - Module to place
   * @param {number} x - Horizontal position of the module
   * @param {number} y - Vertical position of the module
   * @returns {object} A copy of the module, positioned
   */
  alignModule(blueprintModule, x, y) {
    const placed = _.merge({}, blueprintModule, {
      metadata: { designer: { x, y } },
    });
    if (blueprintModule.routes) {
      placed.routes = __.alignRoutes(blueprintModule.routes, x, y);
    }
    if (blueprintModule.onerror) {
      placed.onerror = __.alignFlow(blueprintModule.onerror, x, y + STEP_Y);
    }
    return placed;
  },

  /**
   * Stack routes around the router, each in a slot as tall as its leaf routes
   * @param {object[]} routes - Routes of the router
   * @param {number} x - Horizontal position of the router
   * @param {number} y - Vertical position of the router
   * @returns {object[]} Copies of the routes, with their modules positioned
   */
  alignRoutes(routes, x, y) {
    const heights = _.map(routes, (route) => __.countRows(route.flow, true));
    const total = _.sum(heights);
    return _.map(routes, (route, index) => {
      const slotsBefore = _.chain(heights).take(index).sum().value();
      const ownRows = __.countRows(route.flow);
      const center = slotsBefore + (ownRows - 1) / 2 - (total - 1) / 2;
      return {
        ...route,
        flow: __.alignFlow(route.flow, x + STEP_X, y + center * STEP_Y),
      };
    });
  },

  /**
   * Count the rows a flow needs, at least one. A router needs one row per
   * leaf route. An error handler needs rows under its module
   * @param {object[]} flow - Modules to count
   * @param {boolean} withErrors - Also count the rows of the error handlers
   * @returns {number} Number of rows the flow needs
   */
  countRows(flow, withErrors = false) {
    const heights = _.map(flow, (blueprintModule) => {
      const own = blueprintModule.routes
        ? _.chain(blueprintModule.routes)
            .map((route) => __.countRows(route.flow, true))
            .sum()
            .value()
        : 1;
      const errors =
        withErrors && blueprintModule.onerror
          ? __.countRows(blueprintModule.onerror, true)
          : 0;
      return own + errors;
    });
    return _.max([1, ...heights]);
  },

  /**
   * List every module of a flow, including routes and error handlers
   * @param {object[]} flow - Modules to list
   * @returns {object[]} Flat list of modules
   */
  listModules(flow) {
    return _.flatMap(flow, (blueprintModule) => [
      blueprintModule,
      ...__.listModules(_.flatMap(blueprintModule.routes, 'flow')),
      ...__.listModules(blueprintModule.onerror),
    ]);
  },

  /**
   * Read the vertical position of a module
   * @param {object} blueprintModule - Positioned module
   * @returns {number} The y position
   */
  getY(blueprintModule) {
    return blueprintModule.metadata.designer.y;
  },
};
