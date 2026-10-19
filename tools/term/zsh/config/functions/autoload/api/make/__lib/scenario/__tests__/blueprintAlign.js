import { _ } from 'golgoth';
import { blueprintAlign } from '../blueprintAlign.js';

describe('blueprintAlign', () => {
  it.each([
    {
      title: 'puts one module at x 0 and y 600',
      input: { flow: [{ id: 1, module: 'gateway:CustomWebHook' }] },
      expected: {
        flow: [
          {
            id: 1,
            module: 'gateway:CustomWebHook',
            metadata: { designer: { x: 0, y: 600 } },
          },
        ],
      },
    },
    {
      title: 'puts a chain of modules at steps of 300 on one baseline',
      input: {
        flow: [
          { id: 1, module: 'a' },
          { id: 2, module: 'b' },
          { id: 3, module: 'c' },
        ],
      },
      expected: {
        flow: [
          { id: 1, module: 'a', metadata: { designer: { x: 0, y: 600 } } },
          { id: 2, module: 'b', metadata: { designer: { x: 300, y: 600 } } },
          { id: 3, module: 'c', metadata: { designer: { x: 600, y: 600 } } },
        ],
      },
    },
    {
      title: 'replaces stale positions',
      input: {
        flow: [
          { id: 1, metadata: { designer: { x: 17, y: -42 } } },
          { id: 2, metadata: { designer: { x: 17, y: -42 } } },
        ],
      },
      expected: {
        flow: [
          { id: 1, metadata: { designer: { x: 0, y: 600 } } },
          { id: 2, metadata: { designer: { x: 300, y: 600 } } },
        ],
      },
    },
    {
      title: 'keeps the other fields of every module and of the blueprint',
      input: {
        name: 'Paris Meetup',
        metadata: { version: 1 },
        flow: [
          {
            id: 1,
            module: 'util:SetVariables',
            version: 1,
            mapper: { a: 1 },
            parameters: { b: 2 },
            metadata: { designer: { x: 5, y: 5, name: 'Vars' }, expect: [] },
          },
        ],
      },
      expected: {
        name: 'Paris Meetup',
        metadata: { version: 1 },
        flow: [
          {
            id: 1,
            module: 'util:SetVariables',
            version: 1,
            mapper: { a: 1 },
            parameters: { b: 2 },
            metadata: { designer: { x: 0, y: 600, name: 'Vars' }, expect: [] },
          },
        ],
      },
    },
    {
      title: 'leaves a blueprint without flow untouched',
      input: { name: 'Paris Meetup' },
      expected: { name: 'Paris Meetup' },
    },
  ])('$title', ({ input, expected }) => {
    const actual = blueprintAlign(input);

    expect(actual).toEqual(expected);
  });

  describe('with routers, error handlers and orphans', () => {
    const leaf = (id, extra = {}) => ({ id, module: 'm', ...extra });
    const router = (id, routes, extra = {}) => ({
      id,
      module: 'builtin:BasicRouter',
      routes: _.map(routes, (flow) => ({ flow })),
      ...extra,
    });
    const position = (blueprintModule) => ({
      x: blueprintModule.metadata.designer.x,
      y: blueprintModule.metadata.designer.y,
    });
    const listModules = (flow) =>
      _.flatMap(flow, (blueprintModule) => [
        blueprintModule,
        ...listModules(_.flatMap(blueprintModule.routes, 'flow')),
        ...listModules(blueprintModule.onerror),
      ]);

    it('stacks the routes of a router, centered on the router', () => {
      const input = {
        flow: [
          leaf(1),
          router(2, [
            [leaf(10)],
            [leaf(11)],
            [leaf(12)],
            [leaf(13)],
            [leaf(14)],
          ]),
        ],
      };

      const actual = blueprintAlign(input);

      const routes = actual.flow[1].routes;
      expect(_.map(routes, (route) => position(route.flow[0]))).toEqual([
        { x: 600, y: 0 },
        { x: 600, y: 300 },
        { x: 600, y: 600 },
        { x: 600, y: 900 },
        { x: 600, y: 1200 },
      ]);
    });

    it('continues the modules of a route to the right of the router', () => {
      const input = {
        flow: [router(1, [[leaf(10), leaf(11), leaf(12)], [leaf(13)]])],
      };

      const actual = blueprintAlign(input);

      const route = actual.flow[0].routes[0];
      expect(_.map(route.flow, position)).toEqual([
        { x: 300, y: 450 },
        { x: 600, y: 450 },
        { x: 900, y: 450 },
      ]);
    });

    it('gives a nested router a slot as tall as its leaf routes', () => {
      const input = {
        flow: [
          router(1, [
            [router(10, [[leaf(100)], [leaf(101)], [leaf(102)]])],
            [leaf(11)],
          ]),
        ],
      };

      const actual = blueprintAlign(input);

      const [nested, sibling] = actual.flow[0].routes;
      expect(position(nested.flow[0])).toEqual({ x: 300, y: 450 });
      expect(position(sibling.flow[0])).toEqual({ x: 300, y: 1050 });
    });

    it('centers the routes of a nested router on that router', () => {
      const input = {
        flow: [
          router(1, [
            [router(10, [[leaf(100)], [leaf(101)], [leaf(102)]])],
            [leaf(11)],
          ]),
        ],
      };

      const actual = blueprintAlign(input);

      const nested = actual.flow[0].routes[0].flow[0];
      expect(_.map(nested.routes, (route) => position(route.flow[0]))).toEqual([
        { x: 600, y: 150 },
        { x: 600, y: 450 },
        { x: 600, y: 750 },
      ]);
    });

    it('places an error handler under its module', () => {
      const input = {
        flow: [leaf(1), leaf(2, { onerror: [leaf(20), leaf(21)] })],
      };

      const actual = blueprintAlign(input);

      expect(_.map(actual.flow[1].onerror, position)).toEqual([
        { x: 300, y: 900 },
        { x: 600, y: 900 },
      ]);
    });

    it('reserves the rows of an error handler in the slot of its route', () => {
      const input = {
        flow: [router(1, [[leaf(10, { onerror: [leaf(20)] })], [leaf(11)]])],
      };

      const actual = blueprintAlign(input);

      const [withError, sibling] = actual.flow[0].routes;
      expect(position(withError.flow[0])).toEqual({ x: 300, y: 300 });
      expect(position(withError.flow[0].onerror[0])).toEqual({
        x: 300,
        y: 600,
      });
      expect(position(sibling.flow[0])).toEqual({ x: 300, y: 900 });
    });

    it('places orphans in a row under the flow', () => {
      const input = {
        flow: [leaf(1, { onerror: [leaf(20)] }), leaf(2)],
        metadata: { designer: { orphans: [leaf(30), leaf(31)], other: 1 } },
      };

      const actual = blueprintAlign(input);

      const { orphans, other } = actual.metadata.designer;
      expect(other).toEqual(1);
      expect(_.map(orphans, position)).toEqual([
        { x: 0, y: 1200 },
        { x: 300, y: 1200 },
      ]);
    });

    it('does not add designer metadata when there are no orphans', () => {
      const input = { flow: [leaf(1)], metadata: { version: 1 } };

      const actual = blueprintAlign(input);

      expect(actual).toHaveProperty('metadata', { version: 1 });
    });

    it('aligns a router Blueprint without overlap', () => {
      const input = {
        flow: [
          leaf(2),
          leaf(14),
          leaf(6),
          leaf(23),
          leaf(33),
          router(44, [
            [
              router(27, [
                [leaf(50)],
                [leaf(51)],
                [leaf(52, { onerror: [leaf(60)] })],
                [leaf(53)],
                [leaf(54)],
              ]),
            ],
            [leaf(43)],
          ]),
        ],
        metadata: { designer: { orphans: [leaf(70), leaf(71)] } },
      };

      const actual = blueprintAlign(input);

      const modules = [
        ...listModules(actual.flow),
        ...listModules(actual.metadata.designer.orphans),
      ];
      const positions = _.map(modules, (blueprintModule) =>
        JSON.stringify(position(blueprintModule)),
      );
      expect(_.uniq(positions)).toHaveLength(modules.length);
    });
  });

  it('does not change the input object', () => {
    const input = { flow: [{ id: 1, metadata: { designer: { x: 9, y: 9 } } }] };
    const snapshot = structuredClone(input);

    blueprintAlign(input);

    expect(input).toEqual(snapshot);
  });
});
