import { blueprintValidate } from '../blueprintValidate.js';

describe('blueprintValidate', () => {
  /**
   * Build a valid module, with one required field in its mapper
   * @param {object} overrides - Fields to replace
   * @returns {object} The module
   */
  function buildModule(overrides = {}) {
    return {
      id: 1,
      module: 'http:ActionSendData',
      version: 3,
      mapper: { url: 'https://example.com', gzip: true },
      parameters: { handleErrors: false },
      metadata: {
        expect: [
          { name: 'url', required: true },
          { name: 'gzip', required: true },
          { name: 'method' },
        ],
      },
      ...overrides,
    };
  }

  it('returns no problem for a valid blueprint', () => {
    const input = {
      flow: [
        buildModule({
          id: 1,
          onerror: [buildModule({ id: 2 })],
        }),
        buildModule({
          id: 3,
          routes: [{ flow: [buildModule({ id: 4 })] }],
        }),
      ],
    };

    const actual = blueprintValidate(input);

    expect(actual).toEqual([]);
  });

  it('returns no problem for a blueprint without flow', () => {
    const actual = blueprintValidate({ metadata: { version: 1 } });

    expect(actual).toEqual([]);
  });

  it.each([
    {
      title: 'in the flow',
      input: { flow: [buildModule({ id: 1 }), buildModule({ id: 1 })] },
    },
    {
      title: 'between the flow and a route',
      input: {
        flow: [
          buildModule({ id: 1 }),
          buildModule({
            id: 2,
            routes: [{ flow: [buildModule({ id: 1 })] }],
          }),
        ],
      },
    },
    {
      title: 'between the flow and an error handler',
      input: {
        flow: [
          buildModule({ id: 1 }),
          buildModule({ id: 2, onerror: [buildModule({ id: 1 })] }),
        ],
      },
    },
  ])('reports a duplicate module ID $title', ({ input }) => {
    const actual = blueprintValidate(input);

    expect(actual).toEqual(['Module ID 1 is used more than once']);
  });

  it.each([
    {
      title: 'module',
      input: { flow: [buildModule({ id: 7, module: undefined })] },
      expected: ['Module 7 has no module'],
    },
    {
      title: 'version',
      input: { flow: [buildModule({ id: 7, version: undefined })] },
      expected: ['Module 7 has no version'],
    },
  ])('reports a module without $title', ({ input, expected }) => {
    const actual = blueprintValidate(input);

    expect(actual).toEqual(expected);
  });

  it('reports a required key missing from mapper and parameters', () => {
    const input = {
      flow: [
        buildModule({
          id: 7,
          module: 'http:ActionSendData',
          mapper: { url: 'https://example.com' },
          metadata: {
            expect: [
              { name: 'url', required: true },
              { name: 'gzip', required: true },
              { name: 'followAllRedirects', required: true },
            ],
          },
        }),
      ],
    };

    const actual = blueprintValidate(input);

    expect(actual).toEqual([
      'Module 7 (http:ActionSendData) has no required field gzip',
      'Module 7 (http:ActionSendData) has no required field followAllRedirects',
    ]);
  });

  it('accepts a required key found in parameters', () => {
    const input = {
      flow: [
        buildModule({
          mapper: {},
          parameters: { gzip: true },
          metadata: { expect: [{ name: 'gzip', required: true }] },
        }),
      ],
    };

    const actual = blueprintValidate(input);

    expect(actual).toEqual([]);
  });

  it.each([
    { title: 'false', input: false },
    { title: '0', input: 0 },
    { title: 'an empty string', input: '' },
    { title: 'null', input: null },
  ])('accepts a required key whose value is $title', ({ input: gzip }) => {
    const input = {
      flow: [
        buildModule({
          mapper: { gzip },
          metadata: { expect: [{ name: 'gzip', required: true }] },
        }),
      ],
    };

    const actual = blueprintValidate(input);

    expect(actual).toEqual([]);
  });

  it('checks the modules of routes and error handlers', () => {
    const input = {
      flow: [
        buildModule({
          id: 1,
          routes: [{ flow: [buildModule({ id: 2, version: undefined })] }],
          onerror: [buildModule({ id: 3, module: undefined })],
        }),
      ],
    };

    const actual = blueprintValidate(input);

    expect(actual).toEqual([
      'Module 2 has no version',
      'Module 3 has no module',
    ]);
  });

  it('reports every problem at once', () => {
    const input = {
      flow: [
        buildModule({ id: 1, version: undefined }),
        buildModule({ id: 1, module: undefined }),
        buildModule({
          id: 2,
          mapper: {},
          metadata: { expect: [{ name: 'gzip', required: true }] },
        }),
      ],
    };

    const actual = blueprintValidate(input);

    expect(actual).toEqual([
      'Module ID 1 is used more than once',
      'Module 1 has no version',
      'Module 1 has no module',
      'Module 2 (http:ActionSendData) has no required field gzip',
    ]);
  });
});
