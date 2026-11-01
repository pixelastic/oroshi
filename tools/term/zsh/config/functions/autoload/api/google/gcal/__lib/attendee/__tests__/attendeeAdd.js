import { __, attendeeAdd } from '../attendeeAdd.js';

describe('attendeeAdd', () => {
  const organizer = {
    email: 'org@algolia.com',
    organizer: true,
    responseStatus: 'accepted',
  };
  const bob = { email: 'bob@algolia.com', responseStatus: 'needsAction' };

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      id: 'a',
      attendees: [organizer, bob],
    });
    vi.spyOn(__, 'saveAttendees').mockReturnValue({ eventId: 'a' });
    vi.spyOn(__, 'formatEvent').mockReturnValue({ eventId: 'unchanged' });
  });

  it.each([
    {
      title: 'adds an Attendee and keeps the others',
      emails: ['amy@algolia.com'],
      expected: [organizer, bob, { email: 'amy@algolia.com' }],
    },
    {
      title: 'adds several addresses in one call',
      emails: ['amy@algolia.com', 'cat@algolia.com'],
      expected: [
        organizer,
        bob,
        { email: 'amy@algolia.com' },
        { email: 'cat@algolia.com' },
      ],
    },
    {
      title: 'adds an address once when it is passed twice',
      emails: ['amy@algolia.com', 'AMY@algolia.com'],
      expected: [organizer, bob, { email: 'amy@algolia.com' }],
    },
    {
      title: 'only adds the addresses that are not present yet',
      emails: ['BOB@algolia.com', 'amy@algolia.com'],
      expected: [organizer, bob, { email: 'amy@algolia.com' }],
    },
  ])('$title', async ({ emails, expected }) => {
    await attendeeAdd({ eventId: 'a', emails });

    expect(__.saveAttendees).toHaveBeenCalledWith({
      eventId: 'a',
      calendarId: 'primary',
      attendees: expected,
    });
  });

  it('adds the first Attendee of an Event without any', async () => {
    __.callApi.mockReturnValue({ id: 'a' });

    await attendeeAdd({ eventId: 'a', emails: ['amy@algolia.com'] });

    expect(__.saveAttendees).toHaveBeenCalledWith(
      expect.objectContaining({ attendees: [{ email: 'amy@algolia.com' }] }),
    );
  });

  it('does not save and does not fail when every address is present', async () => {
    const actual = await attendeeAdd({
      eventId: 'a',
      emails: ['bob@algolia.com'],
    });

    expect(__.saveAttendees).not.toHaveBeenCalled();
    expect(__.formatEvent).toHaveBeenCalledWith(
      { id: 'a', attendees: [organizer, bob] },
      'primary',
    );
    expect(actual).toEqual({ eventId: 'unchanged' });
  });

  it('reads the Event of the Calendar given with --calendarId', async () => {
    await attendeeAdd({
      eventId: 'a',
      emails: ['amy@algolia.com'],
      calendarId: 'work@group.calendar.google.com',
    });

    expect(__.callApi).toHaveBeenCalledWith(
      'calendars/work%40group.calendar.google.com/events/a',
    );
    expect(__.saveAttendees).toHaveBeenCalledWith(
      expect.objectContaining({ calendarId: 'work@group.calendar.google.com' }),
    );
  });

  it('returns the saved Event', async () => {
    const actual = await attendeeAdd({
      eventId: 'a',
      emails: ['amy@algolia.com'],
    });

    expect(actual).toEqual({ eventId: 'a' });
  });

  it.each([
    {
      title: 'the eventId is missing',
      input: { eventId: '', emails: ['amy@algolia.com'] },
      code: 'GCAL_EVENT_ID_MISSING',
    },
    {
      title: 'no address is passed',
      input: { eventId: 'a', emails: [] },
      code: 'GCAL_ATTENDEE_MISSING',
    },
  ])('throws when $title', async ({ input, code }) => {
    let actual = null;
    try {
      await attendeeAdd(input);
    } catch (err) {
      actual = err;
    }

    expect(actual).toHaveProperty('code', code);
    expect(__.callApi).not.toHaveBeenCalled();
    expect(__.saveAttendees).not.toHaveBeenCalled();
  });
});
