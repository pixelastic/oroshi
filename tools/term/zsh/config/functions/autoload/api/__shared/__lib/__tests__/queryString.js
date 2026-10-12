import { queryString } from '../queryString.js';

describe('queryString', () => {
  it.each([
    {
      title: 'a list as key[]',
      query: { fields: ['name', 'date'] },
      expected: '?fields%5B%5D=name&fields%5B%5D=date',
    },
    {
      title: 'a list of objects as key[index][property]',
      query: { sort: [{ field: 'name', direction: 'desc' }] },
      expected: '?sort%5B0%5D%5Bfield%5D=name&sort%5B0%5D%5Bdirection%5D=desc',
    },
    {
      title: 'a scalar as key=value',
      query: { pageSize: 10 },
      expected: '?pageSize=10',
    },
    {
      title: 'a value with special characters',
      query: { filterByFormula: "{Name}='Paris & Co'" },
      expected: "?filterByFormula=%7BName%7D%3D'Paris%20%26%20Co'",
    },
    {
      title: 'nothing for empty values',
      query: { pageSize: undefined, fields: [], offset: null },
      expected: '',
    },
    {
      title: 'nothing without a query',
      query: undefined,
      expected: '',
    },
  ])('encodes $title', ({ query, expected }) => {
    const actual = queryString(query);

    expect(actual).toEqual(expected);
  });
});
