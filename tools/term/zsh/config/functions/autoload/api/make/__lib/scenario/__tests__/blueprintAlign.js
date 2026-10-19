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

  it('does not change the input object', () => {
    const input = { flow: [{ id: 1, metadata: { designer: { x: 9, y: 9 } } }] };
    const snapshot = structuredClone(input);

    blueprintAlign(input);

    expect(input).toEqual(snapshot);
  });
});
