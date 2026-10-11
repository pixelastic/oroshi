import { formatTable } from '../formatTable.js';

describe('formatTable', () => {
  it('returns the Table as the API gave it', () => {
    const input = {
      id: 'tblA',
      name: 'Meetups',
      primaryFieldId: 'fldA',
      fields: [{ id: 'fldA', name: 'Title', type: 'singleLineText' }],
      views: [],
    };

    const actual = formatTable(input);

    expect(actual).toEqual(input);
  });
});
