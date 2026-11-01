import { __, getTimeZone } from '../getTimeZone.js';

describe('getTimeZone', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ timeZone: 'Asia/Tokyo' });
  });

  it('returns the time zone of the Calendar', async () => {
    const actual = await getTimeZone('work@group.calendar.google.com');

    expect(__.callApi).toHaveBeenCalledWith(
      'users/me/calendarList/work%40group.calendar.google.com',
    );
    expect(actual).toEqual('Asia/Tokyo');
  });
});
