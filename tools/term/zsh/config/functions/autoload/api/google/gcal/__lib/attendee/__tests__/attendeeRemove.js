import { __, attendeeRemove } from '../attendeeRemove.js';

describe('attendeeRemove', () => {
  const organizer = {
    email: 'org@algolia.com',
    organizer: true,
    responseStatus: 'accepted',
  };
  const bob = { email: 'bob@algolia.com', responseStatus: 'needsAction' };
  const amy = { email: 'amy@algolia.com', responseStatus: 'accepted' };

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      id: 'a',
      attendees: [organizer, bob, amy],
    });
    vi.spyOn(__, 'saveAttendees').mockReturnValue({ eventId: 'a' });
  });

  it.each([
    { title: 'the exact address', emails: ['bob@algolia.com'] },
    { title: 'the address in another case', emails: ['BOB@Algolia.com'] },
  ])(
    'removes one Attendee with $title and keeps the others',
    async ({ emails }) => {
      await attendeeRemove({ eventId: 'a', emails });

      expect(__.saveAttendees).toHaveBeenCalledWith({
        eventId: 'a',
        calendarId: 'primary',
        attendees: [organizer, amy],
      });
    },
  );

  it('returns the saved Event', async () => {
    const actual = await attendeeRemove({
      eventId: 'a',
      emails: ['bob@algolia.com'],
    });

    expect(actual).toEqual({ eventId: 'a' });
  });

  it('reads the Event of the Calendar given with --calendarId', async () => {
    await attendeeRemove({
      eventId: 'a',
      emails: ['bob@algolia.com'],
      calendarId: 'work@group.calendar.google.com',
    });

    expect(__.callApi).toHaveBeenCalledWith(
      'calendars/work%40group.calendar.google.com/events/a',
    );
    expect(__.saveAttendees).toHaveBeenCalledWith(
      expect.objectContaining({ calendarId: 'work@group.calendar.google.com' }),
    );
  });

  it.each([
    {
      title: 'the address is not an Attendee',
      input: { eventId: 'a', emails: ['zed@algolia.com'] },
      code: 'GCAL_ATTENDEE_NOT_FOUND',
    },
    {
      title: 'the address is the organizer',
      input: { eventId: 'a', emails: ['org@algolia.com'] },
      code: 'GCAL_ATTENDEE_ORGANIZER',
    },
    {
      title: 'the eventId is missing',
      input: { eventId: '', emails: ['bob@algolia.com'] },
      code: 'GCAL_EVENT_ID_MISSING',
    },
    {
      title: 'the address is missing',
      input: { eventId: 'a', emails: [] },
      code: 'GCAL_ATTENDEE_MISSING',
    },
    {
      title: 'several addresses are passed',
      input: {
        eventId: 'a',
        emails: ['bob@algolia.com', 'amy@algolia.com'],
      },
      code: 'GCAL_ATTENDEE_TOO_MANY',
    },
  ])('throws before any save when $title', async ({ input, code }) => {
    let actual = null;
    try {
      await attendeeRemove(input);
    } catch (err) {
      actual = err;
    }

    expect(actual).toHaveProperty('code', code);
    expect(__.saveAttendees).not.toHaveBeenCalled();
  });

  it('throws GCAL_ATTENDEE_ORGANIZER when the organizer is not in the Attendees', async () => {
    __.callApi.mockReturnValue({
      id: 'a',
      organizer: { email: 'Org@algolia.com' },
      attendees: [bob],
    });

    let actual = null;
    try {
      await attendeeRemove({ eventId: 'a', emails: ['org@algolia.com'] });
    } catch (err) {
      actual = err;
    }

    expect(actual).toHaveProperty('code', 'GCAL_ATTENDEE_ORGANIZER');
    expect(__.saveAttendees).not.toHaveBeenCalled();
  });

  it('throws GCAL_ATTENDEE_NOT_FOUND for an Event without Attendees', async () => {
    __.callApi.mockReturnValue({ id: 'a' });

    let actual = null;
    try {
      await attendeeRemove({ eventId: 'a', emails: ['bob@algolia.com'] });
    } catch (err) {
      actual = err;
    }

    expect(actual).toHaveProperty('code', 'GCAL_ATTENDEE_NOT_FOUND');
    expect(__.saveAttendees).not.toHaveBeenCalled();
  });
});
