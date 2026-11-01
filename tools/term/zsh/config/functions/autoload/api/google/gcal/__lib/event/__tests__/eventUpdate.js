import { __, eventUpdate } from '../eventUpdate.js';

describe('eventUpdate', () => {
  const timeZone = 'Europe/Paris';
  // The Event as it is before the update: 10:00 to 11:30, 90 minutes
  const timedEvent = {
    start: { dateTime: '2026-11-02T10:00:00+01:00', timeZone },
    end: { dateTime: '2026-11-02T11:30:00+01:00', timeZone },
  };
  // Three days, from the 2nd to the 4th included
  const allDayEvent = {
    start: { date: '2026-11-02' },
    end: { date: '2026-11-05' },
  };

  /**
   * Find the request that patched the Event
   * @returns {Array} Path and options of the PATCH call
   */
  function patchCall() {
    return __.callApi.mock.calls.find(([, options]) => options?.method);
  }

  beforeEach(() => {
    // The API answers the Event as it is, and the updated Event
    vi.spyOn(__, 'callApi').mockImplementation((path, options) =>
      options?.method === 'PATCH' ? { id: 'updated' } : timedEvent,
    );
    vi.spyOn(__, 'getTimeZone').mockReturnValue(timeZone);
    vi.spyOn(__, 'formatEvent').mockReturnValue({ eventId: 'updated' });
  });

  it.each([
    {
      title: 'changes only the fields that are passed',
      input: { title: 'New title' },
      body: { summary: 'New title' },
    },
    {
      title: 'changes the location and the description',
      input: { location: 'Room 2', description: 'New text' },
      body: { location: 'Room 2', description: 'New text' },
    },
    {
      title: 'clears a field passed empty',
      input: { location: '' },
      body: { location: '' },
    },
  ])('$title', async ({ input, body }) => {
    await eventUpdate({ eventId: 'abc', ...input });

    expect(patchCall()).toEqual([
      'calendars/primary/events/abc',
      { method: 'PATCH', query: { sendUpdates: 'none' }, body },
    ]);
  });

  it('reads a long description from --description-file, ahead of --description', async () => {
    vi.spyOn(__, 'read').mockReturnValue('Long text');

    await eventUpdate({
      eventId: 'abc',
      description: 'Short',
      descriptionFile: './about.md',
    });

    const [, { body }] = patchCall();
    expect(__.read).toHaveBeenCalledWith('./about.md');
    expect(body).toEqual({ description: 'Long text' });
  });

  it('keeps the Attendees untouched', async () => {
    await eventUpdate({
      eventId: 'abc',
      title: 'New title',
      dateStart: '2026-11-02T10:00',
      attendees: 'a@algolia.com',
    });

    const [, { body }] = patchCall();
    expect(body).not.toHaveProperty('attendees');
  });

  it('updates the Event of the chosen Calendar', async () => {
    const calendarId = 'work@group.calendar.google.com';

    await eventUpdate({ eventId: 'abc', title: 'New title', calendarId });

    const [path] = patchCall();
    expect(path).toEqual(
      'calendars/work%40group.calendar.google.com/events/abc',
    );
    expect(__.formatEvent).toHaveBeenCalledWith({ id: 'updated' }, calendarId);
  });

  it('sends sendUpdates=none', async () => {
    await eventUpdate({ eventId: 'abc', title: 'New title' });

    const [, { query }] = patchCall();
    expect(query).toEqual({ sendUpdates: 'none' });
  });

  it('returns the Event, formatted with its Calendar', async () => {
    const actual = await eventUpdate({ eventId: 'abc', title: 'New title' });

    expect(__.formatEvent).toHaveBeenCalledWith({ id: 'updated' }, 'primary');
    expect(actual).toEqual({ eventId: 'updated' });
  });

  describe('dates', () => {
    it.each([
      {
        title: 'moves a timed Event to a new start, and keeps its duration',
        event: timedEvent,
        input: { dateStart: '2026-11-05T14:00' },
        start: { dateTime: '2026-11-05T14:00:00', timeZone, date: null },
        end: { dateTime: '2026-11-05T15:30:00', timeZone, date: null },
      },
      {
        title:
          'moves an All-day Event to a new day, and keeps its number of days',
        event: allDayEvent,
        input: { dateStart: '2026-11-10' },
        start: { date: '2026-11-10', dateTime: null, timeZone: null },
        end: { date: '2026-11-13', dateTime: null, timeZone: null },
      },
      {
        title: 'changes only the end when no start is passed',
        event: timedEvent,
        input: { dateEnd: '2026-11-02T12:00' },
        start: { dateTime: '2026-11-02T10:00:00', timeZone, date: null },
        end: { dateTime: '2026-11-02T12:00:00', timeZone, date: null },
      },
      {
        title:
          'turns a timed Event into a one-day All-day Event with a date without time',
        event: timedEvent,
        input: { dateStart: '2026-11-05' },
        start: { date: '2026-11-05', dateTime: null, timeZone: null },
        end: { date: '2026-11-06', dateTime: null, timeZone: null },
      },
      {
        title:
          'turns an All-day Event into a one-hour timed Event with a date with a time',
        event: allDayEvent,
        input: { dateStart: '2026-11-05T14:00' },
        start: { dateTime: '2026-11-05T14:00:00', timeZone, date: null },
        end: { dateTime: '2026-11-05T15:00:00', timeZone, date: null },
      },
    ])('$title', async ({ event, input, start, end }) => {
      __.callApi.mockImplementation((path, options) =>
        options?.method === 'PATCH' ? { id: 'updated' } : event,
      );

      await eventUpdate({ eventId: 'abc', ...input });

      const [, { body }] = patchCall();
      expect(body).toEqual({ start, end });
    });

    it('sets the start and the end given, without reading the Event', async () => {
      await eventUpdate({
        eventId: 'abc',
        dateStart: '2026-11-05T14:00',
        dateEnd: '2026-11-05T14:45',
      });

      const [, { body }] = patchCall();
      expect(body).toEqual({
        start: { dateTime: '2026-11-05T14:00:00', timeZone, date: null },
        end: { dateTime: '2026-11-05T14:45:00', timeZone, date: null },
      });
      expect(__.callApi).toHaveBeenCalledTimes(1);
    });

    it('reads the time as local to the Calendar', async () => {
      const calendarId = 'work@group.calendar.google.com';
      __.getTimeZone.mockReturnValue('Asia/Tokyo');

      await eventUpdate({
        eventId: 'abc',
        dateStart: '2026-11-05T14:00',
        dateEnd: '2026-11-05T15:00',
        calendarId,
      });

      const [, { body }] = patchCall();
      expect(body).toHaveProperty('start.timeZone', 'Asia/Tokyo');
      expect(__.getTimeZone).toHaveBeenCalledWith(calendarId);
    });

    it.each([
      {
        title: 'a date has an offset',
        input: { dateStart: '2026-11-05T14:00+01:00' },
        code: 'GCAL_DATE_INVALID',
      },
      {
        title: 'a start is not a date',
        input: { dateStart: 'tomorrow' },
        code: 'GCAL_DATE_INVALID',
      },
      {
        title: 'an end is not a date',
        input: { dateEnd: '2026-02-30T10:00' },
        code: 'GCAL_DATE_INVALID',
      },
      {
        title: 'a bare flag gives an empty date',
        input: { dateStart: '' },
        code: 'GCAL_DATE_INVALID',
      },
      {
        title: 'the end is before the start',
        input: {
          dateStart: '2026-11-05T14:00',
          dateEnd: '2026-11-05T13:00',
        },
        code: 'GCAL_DATE_RANGE_INVALID',
      },
      {
        title: 'the new end is before the kept start',
        input: { dateEnd: '2026-11-02T09:00' },
        code: 'GCAL_DATE_RANGE_INVALID',
      },
      {
        title: 'the new end is not the same kind as the kept start',
        input: { dateEnd: '2026-11-05' },
        code: 'GCAL_DATE_INVALID',
      },
    ])('throws and updates nothing when $title', async ({ input, code }) => {
      let actual = null;
      try {
        await eventUpdate({ eventId: 'abc', ...input });
      } catch (err) {
        actual = err;
      }

      expect(actual).toHaveProperty('code', code);
      expect(patchCall()).toBeUndefined();
    });
  });

  it('throws and updates nothing without an eventId', async () => {
    let actual = null;
    try {
      await eventUpdate({ title: 'New title' });
    } catch (err) {
      actual = err;
    }

    expect(actual).toHaveProperty('code', 'GCAL_EVENT_ID_MISSING');
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
