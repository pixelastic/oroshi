import { _ } from 'golgoth';
import { __, eventCreate } from '../eventCreate.js';

describe('eventCreate', () => {
  const timeZone = 'Europe/Paris';

  /**
   * Find the request that created the Event
   * @returns {Array} Path and options of the POST call
   */
  function insertCall() {
    return __.callApi.mock.calls.find(([, options]) => options?.method);
  }

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ id: 'created' });
    vi.spyOn(__, 'getTimeZone').mockReturnValue(timeZone);
    vi.spyOn(__, 'formatEvent').mockReturnValue({ eventId: 'created' });
    vi.spyOn(__, 'read').mockReturnValue('Long text');
  });

  it('creates a timed Event with a title and a start, and ends it one hour later', async () => {
    await eventCreate({ title: 'Dentist', dateStart: '2026-11-02T10:00' });

    expect(insertCall()).toEqual([
      'calendars/primary/events',
      expect.objectContaining({
        method: 'POST',
        body: {
          summary: 'Dentist',
          start: { dateTime: '2026-11-02T10:00:00', timeZone },
          end: { dateTime: '2026-11-02T11:00:00', timeZone },
        },
      }),
    ]);
  });

  it('reads the time as local to the Calendar', async () => {
    __.getTimeZone.mockReturnValue('Asia/Tokyo');

    await eventCreate({ title: 'Dentist', dateStart: '2026-11-02T10:00' });

    const [, { body }] = insertCall();
    expect(body).toHaveProperty('start', {
      dateTime: '2026-11-02T10:00:00',
      timeZone: 'Asia/Tokyo',
    });
    expect(__.getTimeZone).toHaveBeenCalledWith('primary');
  });

  it('creates an All-day Event from a date without time, with an inclusive end', async () => {
    await eventCreate({
      title: 'Day off',
      dateStart: '2026-11-02',
      dateEnd: '2026-11-04',
    });

    const [, { body }] = insertCall();
    expect(body).toHaveProperty('start', { date: '2026-11-02' });
    expect(body).toHaveProperty('end', { date: '2026-11-05' });
  });

  it('creates the Event on the chosen Calendar', async () => {
    const calendarId = 'work@group.calendar.google.com';

    await eventCreate({
      title: 'Dentist',
      dateStart: '2026-11-02T10:00',
      calendarId,
    });

    const [path] = insertCall();
    expect(path).toEqual('calendars/work%40group.calendar.google.com/events');
    expect(__.getTimeZone).toHaveBeenCalledWith(calendarId);
    expect(__.formatEvent).toHaveBeenCalledWith({ id: 'created' }, calendarId);
  });

  it('adds the initial Attendees', async () => {
    await eventCreate({
      title: 'Dentist',
      dateStart: '2026-11-02T10:00',
      attendees: 'a@algolia.com, b@algolia.com,,',
    });

    const [, { body }] = insertCall();
    expect(body).toHaveProperty('attendees', [
      { email: 'a@algolia.com' },
      { email: 'b@algolia.com' },
    ]);
  });

  it('sends the recurrence array with the Event', async () => {
    await eventCreate({
      title: 'Stand-up',
      dateStart: '2026-11-04T10:00',
      recurrence: 'FREQ=WEEKLY;BYDAY=WE',
    });

    const [, { body }] = insertCall();
    expect(body).toHaveProperty('recurrence', ['RRULE:FREQ=WEEKLY;BYDAY=WE']);
    expect(body).toHaveProperty('start', {
      dateTime: '2026-11-04T10:00:00',
      timeZone,
    });
  });

  it('leaves recurrence out of the body without the flag', async () => {
    await eventCreate({ title: 'Dentist', dateStart: '2026-11-02T10:00' });

    const [, { body }] = insertCall();
    expect(body).not.toHaveProperty('recurrence');
  });

  it('lets the message of the API about an invalid rule reach the caller', async () => {
    const message = '400 Invalid recurrence rule: FREQ=SOMETIMES';
    __.callApi.mockImplementation(() => {
      throw new Error(message);
    });

    let actual = null;
    try {
      await eventCreate({
        title: 'Stand-up',
        dateStart: '2026-11-04T10:00',
        recurrence: 'FREQ=SOMETIMES',
      });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', message);
  });

  it('adds the location and the description', async () => {
    await eventCreate({
      title: 'Dentist',
      dateStart: '2026-11-02T10:00',
      location: 'Room 1',
      description: 'Bring the file',
    });

    const [, { body }] = insertCall();
    expect(body).toMatchObject({
      location: 'Room 1',
      description: 'Bring the file',
    });
  });

  it('reads a long description from --description-file', async () => {
    await eventCreate({
      title: 'Dentist',
      dateStart: '2026-11-02T10:00',
      descriptionFile: './about.md',
    });

    const [, { body }] = insertCall();
    expect(__.read).toHaveBeenCalledWith('./about.md');
    expect(body).toHaveProperty('description', 'Long text');
  });

  it('prefers --description-file over --description', async () => {
    await eventCreate({
      title: 'Dentist',
      dateStart: '2026-11-02T10:00',
      description: 'Short',
      descriptionFile: './about.md',
    });

    const [, { body }] = insertCall();
    expect(body).toHaveProperty('description', 'Long text');
  });

  it.each([
    {
      title: 'private with isPrivate',
      input: { isPrivate: true },
      expected: 'private',
    },
    {
      title: 'default with isPublic',
      input: { isPublic: true },
      expected: 'default',
    },
  ])('sends visibility $title', async ({ input, expected }) => {
    await eventCreate({
      title: 'Dentist',
      dateStart: '2026-11-02T10:00',
      ...input,
    });

    const [, { body }] = insertCall();
    expect(body).toHaveProperty('visibility', expected);
  });

  it('throws GCAL_VISIBILITY_CONFLICT without calling the API when both flags are set', async () => {
    let actual = null;
    try {
      await eventCreate({
        title: 'Dentist',
        dateStart: '2026-11-02T10:00',
        isPrivate: true,
        isPublic: true,
      });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GCAL_VISIBILITY_CONFLICT');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('sends only the fields it has', async () => {
    await eventCreate({ title: 'Dentist', dateStart: '2026-11-02T10:00' });

    const [, { body }] = insertCall();
    expect(_.chain(body).keys().sort().value()).toEqual([
      'end',
      'start',
      'summary',
    ]);
  });

  it('sends sendUpdates=none', async () => {
    await eventCreate({
      title: 'Dentist',
      dateStart: '2026-11-02T10:00',
      attendees: 'a@algolia.com',
    });

    const [, { query }] = insertCall();
    expect(query).toEqual({ sendUpdates: 'none' });
  });

  it('returns the Event, formatted with its Calendar', async () => {
    const actual = await eventCreate({
      title: 'Dentist',
      dateStart: '2026-11-02T10:00',
    });

    expect(__.formatEvent).toHaveBeenCalledWith({ id: 'created' }, 'primary');
    expect(actual).toEqual({ eventId: 'created' });
  });

  describe('errors', () => {
    it.each([
      {
        title: 'the title is missing',
        input: { dateStart: '2026-11-02T10:00' },
        code: 'GCAL_TITLE_MISSING',
      },
      {
        title: 'the start is missing',
        input: { title: 'Dentist' },
        code: 'GCAL_DATE_START_MISSING',
      },
      {
        title: 'a date has an offset',
        input: { title: 'Dentist', dateStart: '2026-11-02T10:00+01:00' },
        code: 'GCAL_DATE_INVALID',
      },
      {
        title: 'the end is before the start',
        input: {
          title: 'Dentist',
          dateStart: '2026-11-02T10:00',
          dateEnd: '2026-11-02T09:00',
        },
        code: 'GCAL_DATE_RANGE_INVALID',
      },
    ])('throws and creates nothing when $title', async ({ input, code }) => {
      let actual = null;
      try {
        await eventCreate(input);
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', code);
      expect(insertCall()).toBeUndefined();
    });
  });
});
