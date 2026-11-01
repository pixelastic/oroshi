import { dayjs } from 'golgoth';
import { __, listEvents } from '../listEvents.js';

describe('listEvents', () => {
  /**
   * Build a timed Event, as returned by events.list
   * @param {string} id - Event id
   * @param {object} fields - Fields to override
   * @returns {object} Event
   */
  function event(id, fields = {}) {
    return {
      id,
      summary: id,
      status: 'confirmed',
      start: { dateTime: '2026-11-02T10:00:00+01:00' },
      end: { dateTime: '2026-11-02T11:00:00+01:00' },
      ...fields,
    };
  }

  /**
   * Make callApi answer with the given pages, one per call
   * @param {object[][]} pages - The Events of each page
   */
  function mockPages(pages) {
    vi.spyOn(__, 'callApi').mockImplementation((_path, { query }) => {
      const index = query.pageToken ? Number(query.pageToken) : 0;
      const nextPageToken = index + 1 < pages.length ? `${index + 1}` : null;
      return { items: pages[index], ...(nextPageToken && { nextPageToken }) };
    });
  }

  /**
   * Read the ids of the rows
   * @param {string} output - Raw lines
   * @returns {string[]} Event ids
   */
  function ids(output) {
    return output.split('\n').map((line) => line.split('▮')[0]);
  }

  beforeEach(() => {
    mockPages([[]]);
  });

  describe('the request', () => {
    it('asks for the Events of the Calendar, one per occurrence, by start', async () => {
      await listEvents({ calendarId: 'primary' });

      expect(__.callApi).toHaveBeenCalledWith(
        'calendars/primary/events',
        expect.objectContaining({
          query: expect.objectContaining({
            singleEvents: true,
            orderBy: 'startTime',
          }),
        }),
      );
    });

    it('escapes the id of the Calendar', async () => {
      await listEvents({ calendarId: 'work@group.calendar.google.com' });

      expect(__).toHaveProperty(
        'callApi.mock.calls.0.0',
        'calendars/work%40group.calendar.google.com/events',
      );
    });

    it('covers the first day from its start to the end of the last day', async () => {
      await listEvents({
        calendarId: 'primary',
        dateMin: '2026-11-02',
        dateMax: '2026-11-04',
      });

      const { timeMin, timeMax } = __.callApi.mock.calls[0][1].query;
      expect(dayjs(timeMin).format('YYYY-MM-DD HH:mm')).toEqual(
        '2026-11-02 00:00',
      );
      expect(dayjs(timeMax).format('YYYY-MM-DD HH:mm')).toEqual(
        '2026-11-05 00:00',
      );
    });

    it('sets no time bound without a period', async () => {
      await listEvents({ calendarId: 'primary' });

      const { query } = __.callApi.mock.calls[0][1];
      expect([query.timeMin, query.timeMax]).toEqual([undefined, undefined]);
    });

    it('sends the query as the free text of the API', async () => {
      await listEvents({ calendarId: 'primary', query: 'dentist' });

      expect(__.callApi.mock.calls[0][1].query).toHaveProperty('q', 'dentist');
    });
  });

  describe('the lines', () => {
    it('prints one line per Event with eight columns', async () => {
      mockPages([
        [
          event('a', {
            summary: 'Stand-up',
            attendees: [{ email: 'x@y.z' }, { email: 'y@y.z' }],
            location: 'Room 1',
          }),
        ],
      ]);

      const actual = await listEvents({ calendarId: 'primary' });

      expect(actual).toEqual(
        'a▮Stand-up▮confirmed▮2026-11-02T10:00:00+01:00▮2026-11-02T11:00:00+01:00▮false▮2▮Room 1',
      );
    });

    it('prints the Events in the order of the API, sorted by start', async () => {
      mockPages([[event('b'), event('a'), event('c')]]);

      const actual = await listEvents({ calendarId: 'primary' });

      expect(ids(actual)).toEqual(['b', 'a', 'c']);
    });

    it('sets isAllDay and an inclusive dateEnd for an All-day Event', async () => {
      mockPages([
        [
          event('a', {
            start: { date: '2026-11-02' },
            end: { date: '2026-11-03' },
          }),
        ],
      ]);

      const actual = await listEvents({ calendarId: 'primary' });

      const [, , , dateStart, dateEnd, isAllDay] = actual.split('▮');
      expect([dateStart, dateEnd, isAllDay]).toEqual([
        '2026-11-02',
        '2026-11-02',
        'true',
      ]);
    });

    it('has an attendeeCount of 0 without Attendees', async () => {
      mockPages([[event('a')]]);

      const actual = await listEvents({ calendarId: 'primary' });

      expect(actual.split('▮')[6]).toEqual('0');
    });

    it('leaves the title and the location empty when absent', async () => {
      mockPages([[event('a', { summary: undefined })]]);

      const actual = await listEvents({ calendarId: 'primary' });

      const fields = actual.split('▮');
      expect([fields[1], fields[7]]).toEqual(['', '']);
    });

    it('removes the separators from the title', async () => {
      mockPages([[event('a', { summary: 'A▮B\nC' })]]);

      const actual = await listEvents({ calendarId: 'primary' });

      expect(actual.split('▮')[1]).toEqual('AB C');
    });

    it('prints an empty line when there is no Event', async () => {
      const actual = await listEvents({ calendarId: 'primary' });

      expect(actual).toEqual('');
    });
  });

  describe('the limit', () => {
    it('limits the number of lines', async () => {
      mockPages([[event('a'), event('b'), event('c')]]);

      const actual = await listEvents({ calendarId: 'primary', limit: 2 });

      expect(ids(actual)).toEqual(['a', 'b']);
    });

    it('limits to 25 lines by default', async () => {
      mockPages([
        Array.from({ length: 30 }, (_value, index) => event(`e${index}`)),
      ]);

      const actual = await listEvents({ calendarId: 'primary' });

      expect(actual.split('\n')).toHaveLength(25);
    });

    it('reads the next page when the first one is not enough', async () => {
      mockPages([[event('a')], [event('b'), event('c')]]);

      const actual = await listEvents({ calendarId: 'primary', limit: 3 });

      expect(ids(actual)).toEqual(['a', 'b', 'c']);
    });

    it('does not read the next page once the limit is reached', async () => {
      mockPages([[event('a'), event('b')], [event('c')]]);

      await listEvents({ calendarId: 'primary', limit: 2 });

      expect(__.callApi).toHaveBeenCalledTimes(1);
    });
  });
});
