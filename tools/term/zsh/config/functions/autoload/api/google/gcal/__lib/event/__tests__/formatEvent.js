import { formatEvent } from '../formatEvent.js';

describe('formatEvent', () => {
  it('marks an All-day Event and makes its end inclusive', () => {
    const response = {
      id: 'a',
      start: { date: '2026-11-02' },
      end: { date: '2026-11-03' },
    };

    const actual = formatEvent(response);

    expect(actual).toEqual({
      id: 'a',
      isAllDay: true,
      start: { date: '2026-11-02' },
      end: { date: '2026-11-02' },
    });
  });

  it('keeps the last day of an All-day Event of several days', () => {
    const response = {
      start: { date: '2026-12-30' },
      end: { date: '2027-01-02' },
    };

    const actual = formatEvent(response);

    expect(actual).toHaveProperty('end', { date: '2027-01-01' });
  });

  it('does not mark an Event that has a time, and keeps its end', () => {
    const response = {
      id: 'a',
      start: { dateTime: '2026-11-02T10:00:00+01:00' },
      end: { dateTime: '2026-11-02T11:00:00+01:00' },
    };

    const actual = formatEvent(response);

    expect(actual).toEqual({ ...response, isAllDay: false });
  });

  it('does not change the response it receives', () => {
    const response = {
      start: { date: '2026-11-02' },
      end: { date: '2026-11-03' },
    };

    formatEvent(response);

    expect(response).toHaveProperty('end', { date: '2026-11-03' });
  });
});
