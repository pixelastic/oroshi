import { formatRecord } from '../formatRecord.js';

describe('formatRecord', () => {
  it('returns the id and the nested fields of the Record', () => {
    const input = {
      id: 'recA',
      createdTime: '2026-03-12T10:00:00.000Z',
      fields: { Name: 'Paris Meetup', Tags: ['online', 'paris'] },
    };

    const actual = formatRecord(input);

    expect(actual).toEqual({
      id: 'recA',
      fields: { Name: 'Paris Meetup', Tags: ['online', 'paris'] },
    });
  });
});
