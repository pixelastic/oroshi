import { resolveRecurrence } from '../resolveRecurrence.js';

describe('resolveRecurrence', () => {
  it.each([
    {
      title: 'the RRULE: prefix added when it is missing',
      input: 'FREQ=WEEKLY;BYDAY=WE',
      expected: ['RRULE:FREQ=WEEKLY;BYDAY=WE'],
    },
    {
      title: 'the RRULE: prefix kept when it exists',
      input: 'RRULE:FREQ=WEEKLY;BYDAY=WE',
      expected: ['RRULE:FREQ=WEEKLY;BYDAY=WE'],
    },
    {
      title: 'an empty array for an empty value',
      input: '',
      expected: [],
    },
    {
      title: 'undefined when the flag is not passed',
      input: undefined,
      expected: undefined,
    },
  ])('returns $title', ({ input, expected }) => {
    const actual = resolveRecurrence(input);

    expect(actual).toEqual(expected);
  });
});
