import { __, eventSearch } from '../eventSearch.js';

describe('eventSearch', () => {
  beforeEach(() => {
    vi.spyOn(__, 'getToday').mockReturnValue('2026-10-31');
    vi.spyOn(__, 'resolveDateRange').mockReturnValue({
      dateMin: '2026-11-02',
      dateMax: '2026-11-04',
    });
    vi.spyOn(__, 'listEvents').mockReturnValue('a▮Dentist');
  });

  it('returns the lines of the Events found', async () => {
    const actual = await eventSearch({ query: 'dentist' });

    expect(actual).toEqual('a▮Dentist');
  });

  it.each([
    {
      title: 'sends the query of the user as the free text of the search',
      input: { query: 'dentist appointment' },
      expected: { query: 'dentist appointment' },
    },
    {
      title: 'searches the Primary by default',
      input: { query: 'dentist' },
      expected: { calendarId: 'primary' },
    },
    {
      title: 'searches the Calendar given with --calendarId',
      input: { query: 'dentist', calendarId: 'work@group.calendar.google.com' },
      expected: { calendarId: 'work@group.calendar.google.com' },
    },
    {
      title: 'passes the limit',
      input: { query: 'dentist', limit: 3 },
      expected: { limit: 3 },
    },
  ])('$title', async ({ input, expected }) => {
    await eventSearch(input);

    expect(__.listEvents).toHaveBeenCalledWith(
      expect.objectContaining(expected),
    );
  });

  it.each([
    { title: 'no flag', input: {} },
    { title: 'only a limit', input: { limit: 3 } },
    // The bin sets the booleans to false when absent
    {
      title: 'the booleans set to false',
      input: { today: false, week: false },
    },
  ])('sets no date bound with $title', async ({ input }) => {
    await eventSearch({ query: 'dentist', ...input });

    expect(__.resolveDateRange).not.toHaveBeenCalled();
    expect(__.listEvents).toHaveBeenCalledWith(
      expect.not.objectContaining({ dateMin: expect.anything() }),
    );
  });

  it.each([
    { title: '--date-min', input: { dateMin: '2026-11-02' } },
    { title: '--date-max', input: { dateMax: '2026-11-04' } },
    { title: 'an empty --date-min', input: { dateMin: '' } },
    { title: '--today', input: { today: true } },
    { title: '--week', input: { week: true } },
  ])('applies the period of $title when given', async ({ input }) => {
    await eventSearch({ query: 'dentist', ...input });

    expect(__.resolveDateRange).toHaveBeenCalledWith(
      expect.objectContaining(input),
      '2026-10-31',
    );
    expect(__.listEvents).toHaveBeenCalledWith(
      expect.objectContaining({ dateMin: '2026-11-02', dateMax: '2026-11-04' }),
    );
  });

  it('fails without a query', async () => {
    let actual = null;
    try {
      await eventSearch({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GCAL_QUERY_MISSING');
  });
});
