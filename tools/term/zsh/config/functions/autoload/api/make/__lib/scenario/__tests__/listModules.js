import { listModules } from '../listModules.js';

describe('listModules', () => {
  it('lists the modules of the flow, the routes and the error handlers', () => {
    const input = [
      { id: 1 },
      {
        id: 2,
        routes: [
          { flow: [{ id: 3 }] },
          { flow: [{ id: 4, onerror: [{ id: 5 }] }] },
        ],
        onerror: [{ id: 6 }],
      },
    ];

    const actual = listModules(input);

    expect(actual.map((blueprintModule) => blueprintModule.id).sort()).toEqual([
      1, 2, 3, 4, 5, 6,
    ]);
  });

  it('returns an empty list without flow', () => {
    const actual = listModules(undefined);

    expect(actual).toEqual([]);
  });
});
