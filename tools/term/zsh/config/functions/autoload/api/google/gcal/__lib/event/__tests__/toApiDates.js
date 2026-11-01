import { toApiDates } from '../toApiDates.js';

describe('toApiDates', () => {
  const timeZone = 'Europe/Paris';

  describe('timed Event', () => {
    it.each([
      {
        title: 'ends one hour after the start with no end',
        input: { dateStart: '2026-11-02T10:00' },
        expected: {
          start: { dateTime: '2026-11-02T10:00:00', timeZone },
          end: { dateTime: '2026-11-02T11:00:00', timeZone },
        },
      },
      {
        title: 'ends one hour after the start across midnight',
        input: { dateStart: '2026-11-02T23:30' },
        expected: {
          start: { dateTime: '2026-11-02T23:30:00', timeZone },
          end: { dateTime: '2026-11-03T00:30:00', timeZone },
        },
      },
      {
        title: 'ends one hour after the start across a month',
        input: { dateStart: '2026-11-30T23:30' },
        expected: {
          start: { dateTime: '2026-11-30T23:30:00', timeZone },
          end: { dateTime: '2026-12-01T00:30:00', timeZone },
        },
      },
      {
        title: 'keeps the end given',
        input: { dateStart: '2026-11-02T10:00', dateEnd: '2026-11-02T12:15' },
        expected: {
          start: { dateTime: '2026-11-02T10:00:00', timeZone },
          end: { dateTime: '2026-11-02T12:15:00', timeZone },
        },
      },
      {
        title: 'accepts an end equal to the start',
        input: { dateStart: '2026-11-02T10:00', dateEnd: '2026-11-02T10:00' },
        expected: {
          start: { dateTime: '2026-11-02T10:00:00', timeZone },
          end: { dateTime: '2026-11-02T10:00:00', timeZone },
        },
      },
    ])('$title', ({ input, expected }) => {
      const actual = toApiDates({ ...input, timeZone });

      expect(actual).toEqual(expected);
    });

    it('reads the time in the time zone given, whatever the zone', () => {
      const actual = toApiDates({
        dateStart: '2026-11-02T10:00',
        timeZone: 'America/New_York',
      });

      expect(actual).toHaveProperty('start', {
        dateTime: '2026-11-02T10:00:00',
        timeZone: 'America/New_York',
      });
    });

    it('adds an hour on the clock, even on the night the clocks change', () => {
      // 2026-03-29 is the day Paris moves to summer time at 02:00
      const actual = toApiDates({ dateStart: '2026-03-29T01:30', timeZone });

      expect(actual).toHaveProperty('end.dateTime', '2026-03-29T02:30:00');
    });
  });

  describe('All-day Event', () => {
    it.each([
      {
        title: 'lasts one day with no end',
        input: { dateStart: '2026-11-02' },
        expected: {
          start: { date: '2026-11-02' },
          end: { date: '2026-11-03' },
        },
      },
      {
        title: 'lasts one day when the end is the start',
        input: { dateStart: '2026-11-02', dateEnd: '2026-11-02' },
        expected: {
          start: { date: '2026-11-02' },
          end: { date: '2026-11-03' },
        },
      },
      {
        title: 'gives the day after the last day as the end',
        input: { dateStart: '2026-11-02', dateEnd: '2026-11-04' },
        expected: {
          start: { date: '2026-11-02' },
          end: { date: '2026-11-05' },
        },
      },
      {
        title: 'gives the first day of the next month as the end',
        input: { dateStart: '2026-11-29', dateEnd: '2026-11-30' },
        expected: {
          start: { date: '2026-11-29' },
          end: { date: '2026-12-01' },
        },
      },
      {
        title: 'gives the first day of the next year as the end',
        input: { dateStart: '2026-12-31' },
        expected: {
          start: { date: '2026-12-31' },
          end: { date: '2027-01-01' },
        },
      },
    ])('$title', ({ input, expected }) => {
      const actual = toApiDates({ ...input, timeZone });

      expect(actual).toEqual(expected);
    });
  });

  describe('errors', () => {
    it.each([
      { title: 'a date with a Z offset', dateStart: '2026-11-02T10:00:00Z' },
      {
        title: 'a date with a positive offset',
        dateStart: '2026-11-02T10:00:00+01:00',
      },
      {
        title: 'a date with a negative offset',
        dateStart: '2026-11-02T10:00-05:00',
      },
      { title: 'a date with seconds', dateStart: '2026-11-02T10:00:00' },
      { title: 'a date that does not exist', dateStart: '2026-02-30' },
      { title: 'a time that does not exist', dateStart: '2026-11-02T25:00' },
      { title: 'a date in another format', dateStart: '02/11/2026' },
      { title: 'a word', dateStart: 'tomorrow' },
      { title: 'an empty date', dateStart: '' },
    ])('rejects $title as a start', ({ dateStart }) => {
      let actual = null;
      try {
        toApiDates({ dateStart, timeZone });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'GCAL_DATE_INVALID');
    });

    it.each([
      { title: 'a date with an offset', dateEnd: '2026-11-02T12:00+01:00' },
      { title: 'a date that does not exist', dateEnd: '2026-11-31T12:00' },
      { title: 'an empty date', dateEnd: '' },
    ])('rejects $title as an end', ({ dateEnd }) => {
      let actual = null;
      try {
        toApiDates({ dateStart: '2026-11-02T10:00', dateEnd, timeZone });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'GCAL_DATE_INVALID');
    });

    it.each([
      {
        title: 'a timed start with an all-day end',
        dateStart: '2026-11-02T10:00',
        dateEnd: '2026-11-02',
      },
      {
        title: 'an all-day start with a timed end',
        dateStart: '2026-11-02',
        dateEnd: '2026-11-02T10:00',
      },
    ])('rejects $title', ({ dateStart, dateEnd }) => {
      let actual = null;
      try {
        toApiDates({ dateStart, dateEnd, timeZone });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'GCAL_DATE_INVALID');
    });

    it.each([
      {
        title: 'a timed end before the start',
        dateStart: '2026-11-02T10:00',
        dateEnd: '2026-11-02T09:59',
      },
      {
        title: 'a timed end on the day before',
        dateStart: '2026-11-02T10:00',
        dateEnd: '2026-11-01T11:00',
      },
      {
        title: 'an all-day end before the start',
        dateStart: '2026-11-02',
        dateEnd: '2026-11-01',
      },
    ])('rejects $title', ({ dateStart, dateEnd }) => {
      let actual = null;
      try {
        toApiDates({ dateStart, dateEnd, timeZone });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'GCAL_DATE_RANGE_INVALID');
    });

    it('rejects a missing start', () => {
      let actual = null;
      try {
        toApiDates({ timeZone });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'GCAL_DATE_START_MISSING');
    });
  });
});
