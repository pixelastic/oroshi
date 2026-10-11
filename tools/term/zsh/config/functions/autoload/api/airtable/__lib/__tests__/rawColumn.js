import { airtableRawColumn } from '../rawColumn.js';

describe('airtableRawColumn', () => {
  const separators = { field: '▮', list: '▯' };

  it.each([
    { title: 'keeps a plain string', input: 'Paris', expected: 'Paris' },
    {
      title: 'turns newlines into a space',
      input: 'Line one\n  Line two',
      expected: 'Line one Line two',
    },
    {
      title: 'removes both separators',
      input: 'a▮b▯c',
      expected: 'abc',
    },
    {
      title: 'joins a list with the lighter separator',
      input: ['a', 'b'],
      expected: 'a▯b',
    },
    { title: 'leaves an empty value empty', input: undefined, expected: '' },
    {
      title: 'serializes an object as JSON',
      input: { id: 'att1' },
      expected: '{"id":"att1"}',
    },
  ])('$title', ({ input, expected }) => {
    const actual = airtableRawColumn(input, separators);
    expect(actual).toEqual(expected);
  });
});
