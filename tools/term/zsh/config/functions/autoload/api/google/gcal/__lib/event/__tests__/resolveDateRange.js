import { resolveDateRange } from '../resolveDateRange.js';

describe('resolveDateRange', () => {
  it.each([
    {
      title: 'is today and the next 7 days with no flag',
      flags: {},
      expected: { dateMin: '2026-10-31', dateMax: '2026-11-07' },
    },
    {
      title: 'fixes both bounds to today with --today',
      flags: { today: true },
      expected: { dateMin: '2026-10-31', dateMax: '2026-10-31' },
    },
  ])('$title', ({ flags, expected }) => {
    // A Saturday
    const actual = resolveDateRange(flags, '2026-10-31');

    expect(actual).toEqual(expected);
  });
});

describe('resolveDateRange with --week', () => {
  it.each([
    {
      title: 'a Monday',
      today: '2026-10-26',
      dateMin: '2026-10-26',
      dateMax: '2026-11-01',
    },
    {
      title: 'a Wednesday',
      today: '2026-10-28',
      dateMin: '2026-10-26',
      dateMax: '2026-11-01',
    },
    {
      title: 'a Saturday',
      today: '2026-10-31',
      dateMin: '2026-10-26',
      dateMax: '2026-11-01',
    },
    {
      title: 'a Sunday',
      today: '2026-11-01',
      dateMin: '2026-10-26',
      dateMax: '2026-11-01',
    },
    {
      title: 'the end of the year',
      today: '2026-12-31',
      dateMin: '2026-12-28',
      dateMax: '2027-01-03',
    },
  ])(
    'is Monday to Sunday of the current week on $title',
    ({ today, dateMin, dateMax }) => {
      const actual = resolveDateRange({ week: true }, today);

      expect(actual).toEqual({ dateMin, dateMax });
    },
  );
});

describe('resolveDateRange with explicit bounds', () => {
  const today = '2026-10-31';

  it.each([
    {
      title: 'both bounds',
      flags: { dateMin: '2026-11-02', dateMax: '2026-11-04' },
      expected: { dateMin: '2026-11-02', dateMax: '2026-11-04' },
    },
    {
      title: 'only a minimum is 7 days long',
      flags: { dateMin: '2026-11-02' },
      expected: { dateMin: '2026-11-02', dateMax: '2026-11-09' },
    },
    {
      title: 'only a maximum starts 7 days before it',
      flags: { dateMax: '2026-11-09' },
      expected: { dateMin: '2026-11-02', dateMax: '2026-11-09' },
    },
    {
      title: 'a minimum equal to the maximum',
      flags: { dateMin: '2026-11-02', dateMax: '2026-11-02' },
      expected: { dateMin: '2026-11-02', dateMax: '2026-11-02' },
    },
  ])('resolves $title', ({ flags, expected }) => {
    const actual = resolveDateRange(flags, today);

    expect(actual).toEqual(expected);
  });

  it.each([
    { title: 'a bad format', flags: { dateMin: '02/11/2026' } },
    { title: 'a day that does not exist', flags: { dateMax: '2026-02-30' } },
    { title: 'a missing value', flags: { dateMin: '' } },
  ])('throws GCAL_DATE_INVALID on $title', ({ flags }) => {
    let actual = null;
    try {
      resolveDateRange(flags, today);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GCAL_DATE_INVALID');
  });

  it('throws GCAL_DATE_RANGE_INVALID when the minimum is after the maximum', () => {
    let actual = null;
    try {
      resolveDateRange({ dateMin: '2026-11-05', dateMax: '2026-11-04' }, today);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GCAL_DATE_RANGE_INVALID');
  });
});
