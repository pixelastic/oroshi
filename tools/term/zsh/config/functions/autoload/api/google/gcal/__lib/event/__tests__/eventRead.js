import { __, eventRead } from '../eventRead.js';

describe('eventRead', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ id: 'a' });
    vi.spyOn(__, 'formatEvent').mockReturnValue({ eventId: 'a' });
  });

  it.each([
    {
      title: 'asks for the Event in the Primary by default',
      input: { eventId: 'a' },
      expected: 'calendars/primary/events/a',
    },
    {
      title: 'asks for the Event in the Calendar given with --calendarId',
      input: { eventId: 'a', calendarId: 'work@group.calendar.google.com' },
      expected: 'calendars/work%40group.calendar.google.com/events/a',
    },
    {
      title: 'encodes the eventId in the path',
      input: { eventId: 'a/b' },
      expected: 'calendars/primary/events/a%2Fb',
    },
  ])('$title', async ({ input, expected }) => {
    await eventRead(input);

    expect(__.callApi).toHaveBeenCalledWith(expected);
  });

  it('returns the Event formatted with its Calendar', async () => {
    const actual = await eventRead({ eventId: 'a', calendarId: 'work' });

    expect(__.formatEvent).toHaveBeenCalledWith({ id: 'a' }, 'work');
    expect(actual).toEqual({ eventId: 'a' });
  });

  it('throws when the eventId is missing', async () => {
    let actual = null;
    try {
      await eventRead({ eventId: '' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GCAL_EVENT_ID_MISSING');
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
