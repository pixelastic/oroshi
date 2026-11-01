import { __, eventListRaw } from '../eventListRaw.js';

describe('eventListRaw', () => {
  beforeEach(() => {
    vi.spyOn(__, 'getToday').mockReturnValue('2026-10-31');
    vi.spyOn(__, 'resolveDateRange').mockReturnValue({
      dateMin: '2026-11-02',
      dateMax: '2026-11-04',
    });
    vi.spyOn(__, 'listEvents').mockReturnValue('a▮Stand-up');
  });

  it('returns the lines of the Events', async () => {
    const actual = await eventListRaw({});

    expect(actual).toEqual('a▮Stand-up');
  });

  it('resolves the period from the flags and today', async () => {
    await eventListRaw({ week: true });

    expect(__.resolveDateRange).toHaveBeenCalledWith(
      { week: true },
      '2026-10-31',
    );
  });

  it('lists the Events of the resolved period', async () => {
    await eventListRaw({});

    expect(__.listEvents).toHaveBeenCalledWith(
      expect.objectContaining({ dateMin: '2026-11-02', dateMax: '2026-11-04' }),
    );
  });

  it('lists the Events of the Primary by default', async () => {
    await eventListRaw({});

    expect(__.listEvents).toHaveBeenCalledWith(
      expect.objectContaining({ calendarId: 'primary' }),
    );
  });

  it('lists the Events of the Calendar given with --calendarId', async () => {
    await eventListRaw({ calendarId: 'work@group.calendar.google.com' });

    expect(__.listEvents).toHaveBeenCalledWith(
      expect.objectContaining({ calendarId: 'work@group.calendar.google.com' }),
    );
  });

  it('passes the limit', async () => {
    await eventListRaw({ limit: 3 });

    expect(__.listEvents).toHaveBeenCalledWith(
      expect.objectContaining({ limit: 3 }),
    );
  });
});
