import { fromApiDates } from '../fromApiDates.js';

describe('fromApiDates', () => {
  it('keeps the times of a timed Event as the API gives them', () => {
    const start = {
      dateTime: '2026-11-02T10:00:00+01:00',
      timeZone: 'Europe/Paris',
    };
    const end = {
      dateTime: '2026-11-02T11:00:00+01:00',
      timeZone: 'Europe/Paris',
    };

    const actual = fromApiDates(start, end);

    expect(actual).toEqual({
      dateStart: '2026-11-02T10:00:00+01:00',
      dateEnd: '2026-11-02T11:00:00+01:00',
      isAllDay: false,
    });
  });

  it.each([
    {
      title: 'gives the same day for a one-day All-day Event',
      start: '2026-11-02',
      end: '2026-11-03',
      expected: '2026-11-02',
    },
    {
      title: 'gives the last day of a longer All-day Event',
      start: '2026-11-02',
      end: '2026-11-05',
      expected: '2026-11-04',
    },
    {
      title: 'gives the last day of the month',
      start: '2026-11-30',
      end: '2026-12-01',
      expected: '2026-11-30',
    },
    {
      title: 'gives the last day of the year',
      start: '2026-12-31',
      end: '2027-01-01',
      expected: '2026-12-31',
    },
  ])('$title', ({ start, end, expected }) => {
    const actual = fromApiDates({ date: start }, { date: end });

    expect(actual).toEqual({
      dateStart: start,
      dateEnd: expected,
      isAllDay: true,
    });
  });
});
