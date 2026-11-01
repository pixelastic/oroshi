import { getEventsPath } from '../getEventsPath.js';

describe('getEventsPath', () => {
  it('returns the path of the Events of a Calendar', () => {
    const actual = getEventsPath('primary');

    expect(actual).toEqual('calendars/primary/events');
  });

  it('encodes the id of the Calendar', () => {
    const actual = getEventsPath('work@group.calendar.google.com');

    expect(actual).toEqual('calendars/work%40group.calendar.google.com/events');
  });
});
