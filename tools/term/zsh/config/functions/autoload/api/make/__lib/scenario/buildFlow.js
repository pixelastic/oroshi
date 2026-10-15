import { _ } from 'golgoth';

/**
 * Turn the flow of a blueprint into a trimmed, nested flow
 * @param {object[]} blueprintFlow - The flow of the blueprint
 * @returns {object[]} The modules, with their filter name, and the routes of the routers
 */
export function buildFlow(blueprintFlow) {
  return _.map(blueprintFlow, (blueprintModule) => {
    const { id, module, filter, routes } = blueprintModule;
    const result = { id, module };
    if (filter) {
      result.filter = filter.name;
    }
    if (routes) {
      result.routes = _.map(routes, (route) => ({
        // The filter of a route is the one of its first module
        filter: _.get(route, 'flow[0].filter.name'),
        flow: buildFlow(route.flow),
      }));
    }
    return result;
  });
}
