import { __, eventRespond } from '../eventRespond.js';

describe('eventRespond', () => {
  const organizer = {
    email: 'org@algolia.com',
    organizer: true,
    responseStatus: 'accepted',
    comment: 'See you there',
  };
  const self = {
    email: 'me@algolia.com',
    self: true,
    responseStatus: 'needsAction',
  };
  const amy = {
    email: 'amy@algolia.com',
    responseStatus: 'tentative',
    comment: 'Maybe',
  };

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      id: 'a',
      attendees: [organizer, self, amy],
    });
    vi.spyOn(__, 'saveAttendees').mockReturnValue({ eventId: 'a' });
  });

  it('patches the Response of Self and keeps the other Attendees untouched', async () => {
    await eventRespond({ eventId: 'a', responseStatus: 'declined' });

    expect(__.saveAttendees).toHaveBeenCalledWith({
      eventId: 'a',
      calendarId: 'primary',
      attendees: [organizer, { ...self, responseStatus: 'declined' }, amy],
    });
  });

  it('reads the Event of the Primary by default', async () => {
    await eventRespond({ eventId: 'a', responseStatus: 'declined' });

    expect(__.callApi).toHaveBeenCalledWith('calendars/primary/events/a');
  });

  it('uses the Calendar given in calendarId', async () => {
    await eventRespond({
      eventId: 'a',
      responseStatus: 'declined',
      calendarId: 'work@group.calendar.google.com',
    });

    expect(__.callApi).toHaveBeenCalledWith(
      'calendars/work%40group.calendar.google.com/events/a',
    );
    expect(__.saveAttendees).toHaveBeenCalledWith(
      expect.objectContaining({ calendarId: 'work@group.calendar.google.com' }),
    );
  });

  it('returns the updated Event formatted by formatEvent', async () => {
    const actual = await eventRespond({
      eventId: 'a',
      responseStatus: 'declined',
    });

    expect(actual).toEqual({ eventId: 'a' });
  });

  it.each([
    {
      title: 'no Attendee is Self',
      event: { id: 'a', attendees: [organizer, amy] },
      input: { eventId: 'a', responseStatus: 'declined' },
      code: 'GCAL_ATTENDEE_SELF_NOT_FOUND',
    },
    {
      title: 'the Event has no Attendees',
      event: { id: 'a' },
      input: { eventId: 'a', responseStatus: 'declined' },
      code: 'GCAL_ATTENDEE_SELF_NOT_FOUND',
    },
    {
      title: 'the eventId is empty',
      event: { id: 'a', attendees: [self] },
      input: { eventId: '', responseStatus: 'declined' },
      code: 'GCAL_EVENT_ID_MISSING',
    },
  ])(
    'throws $code before any save when $title',
    async ({ event, input, code }) => {
      __.callApi.mockReturnValue(event);

      let actual = null;
      try {
        await eventRespond(input);
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', code);
      expect(__.saveAttendees).not.toHaveBeenCalled();
    },
  );
});
