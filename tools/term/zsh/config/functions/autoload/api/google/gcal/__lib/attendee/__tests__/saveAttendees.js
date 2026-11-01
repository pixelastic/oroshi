import { __, saveAttendees } from '../saveAttendees.js';

describe('saveAttendees', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ id: 'a' });
    vi.spyOn(__, 'formatEvent').mockReturnValue({ eventId: 'a' });
  });

  it('patches the attendees without notifying anyone', async () => {
    const attendees = [{ email: 'a@algolia.com' }];

    await saveAttendees({ eventId: 'a', calendarId: 'primary', attendees });

    expect(__.callApi).toHaveBeenCalledWith('calendars/primary/events/a', {
      method: 'PATCH',
      query: { sendUpdates: 'none' },
      body: { attendees },
    });
  });

  it('encodes the calendarId and the eventId in the path', async () => {
    await saveAttendees({
      eventId: 'a/b',
      calendarId: 'work@group.calendar.google.com',
      attendees: [],
    });

    expect(__.callApi).toHaveBeenCalledWith(
      'calendars/work%40group.calendar.google.com/events/a%2Fb',
      expect.anything(),
    );
  });

  it('returns the Event formatted with its calendarId', async () => {
    const actual = await saveAttendees({
      eventId: 'a',
      calendarId: 'work',
      attendees: [],
    });

    expect(__.formatEvent).toHaveBeenCalledWith({ id: 'a' }, 'work');
    expect(actual).toEqual({ eventId: 'a' });
  });
});
