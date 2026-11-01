import { getToday } from '../getToday.js';

describe('getToday', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date(2026, 10, 1, 12, 0, 0));
  });
  afterEach(() => {
    vi.useRealTimers();
  });

  it('returns today as YYYY-MM-DD', () => {
    const actual = getToday();

    expect(actual).toEqual('2026-11-01');
  });
});
