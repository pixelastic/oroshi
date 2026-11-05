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

  it.each([
    { responseStatus: 'accepted' },
    { responseStatus: 'declined' },
    { responseStatus: 'tentative' },
  ])(
    'patches the Response of Self to $responseStatus and keeps the other Attendees untouched',
    async ({ responseStatus }) => {
      await eventRespond({ eventId: 'a', responseStatus });

      expect(__.saveAttendees).toHaveBeenCalledWith({
        eventId: 'a',
        calendarId: 'primary',
        attendees: [organizer, { ...self, responseStatus }, amy],
      });
    },
  );

  it('changes only the occurrence when the eventId is an occurrence', async () => {
    const occurrenceId = 'a_20261105T100000Z';

    await eventRespond({ eventId: occurrenceId, responseStatus: 'accepted' });

    expect(__.callApi).toHaveBeenCalledWith(
      `calendars/primary/events/${occurrenceId}`,
    );
    expect(__.saveAttendees).toHaveBeenCalledWith({
      eventId: occurrenceId,
      calendarId: 'primary',
      attendees: [organizer, { ...self, responseStatus: 'accepted' }, amy],
    });
  });

  describe('comment', () => {
    const selfWithComment = { ...self, comment: 'Original' };

    beforeEach(() => {
      __.callApi.mockReturnValue({
        id: 'a',
        attendees: [organizer, selfWithComment, amy],
      });
    });

    it.each([
      {
        title: 'sets the Comment of Self',
        input: { comment: 'Too late for me' },
        expected: 'Too late for me',
      },
      {
        title: 'keeps the existing Comment when no comment is passed',
        input: {},
        expected: 'Original',
      },
      {
        title: 'clears the Comment when the comment is empty',
        input: { comment: '' },
        expected: '',
      },
    ])('$title', async ({ input, expected }) => {
      await eventRespond({
        eventId: 'a',
        responseStatus: 'declined',
        ...input,
      });

      expect(__.saveAttendees).toHaveBeenCalledWith({
        eventId: 'a',
        calendarId: 'primary',
        attendees: [
          organizer,
          { ...selfWithComment, responseStatus: 'declined', comment: expected },
          amy,
        ],
      });
    });

    it('keeps the Comment of the other Attendees', async () => {
      await eventRespond({
        eventId: 'a',
        responseStatus: 'declined',
        comment: 'Too late for me',
      });

      const { attendees } = __.saveAttendees.mock.calls[0][0];
      expect(attendees).toHaveProperty('0', organizer);
      expect(attendees).toHaveProperty('2', amy);
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
