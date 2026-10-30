import { formatCalendar } from '../formatCalendar.js';

describe('formatCalendar', () => {
  it('returns the Calendar as the API gave it', () => {
    const response = { id: 'a@b.c', summary: 'Work', timeZone: 'UTC' };

    const actual = formatCalendar(response);

    expect(actual).toEqual(response);
  });
});
