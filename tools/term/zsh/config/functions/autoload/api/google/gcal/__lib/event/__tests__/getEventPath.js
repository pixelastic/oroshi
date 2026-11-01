import { getEventPath } from '../getEventPath.js';

describe('getEventPath', () => {
  it('returns the path of one Event', () => {
    const actual = getEventPath('primary', 'abc123');

    expect(actual).toEqual('calendars/primary/events/abc123');
  });

  it('encodes both ids', () => {
    const actual = getEventPath('work@group.calendar.google.com', 'a/b');

    expect(actual).toEqual(
      'calendars/work%40group.calendar.google.com/events/a%2Fb',
    );
  });

  it.each([[''], [undefined]])(
    'throws GCAL_EVENT_ID_MISSING for the eventId %j',
    (eventId) => {
      let actual = null;
      try {
        getEventPath('primary', eventId);
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'GCAL_EVENT_ID_MISSING');
    },
  );
});
