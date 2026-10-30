import { __, calendarListRaw } from '../calendarListRaw.js';

describe('calendarListRaw', () => {
  /**
   * Build a Calendar, as returned by calendarList.list
   * @param {string} id - Calendar id
   * @param {object} fields - Fields to override
   * @returns {object} Calendar list entry
   */
  function calendar(id, fields = {}) {
    return { id, summary: id, timeZone: 'Europe/Paris', ...fields };
  }

  /**
   * Make callApi answer with the given pages, one per call
   * @param {object[][]} pages - The Calendars of each page
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
   * @returns {string[]} Calendar ids
   */
  function ids(output) {
    return output.split('\n').map((line) => line.split('▮')[0]);
  }

  it('asks the API for the Calendar list', async () => {
    mockPages([[]]);

    await calendarListRaw({});

    expect(__.callApi).toHaveBeenCalledWith('users/me/calendarList', {
      query: { maxResults: 250, pageToken: null },
    });
  });

  it('prints one line per Calendar with four columns', async () => {
    mockPages([
      [
        calendar('work@example.com', {
          summary: 'Work',
          timeZone: 'Europe/London',
        }),
        calendar('me@example.com', {
          summary: 'Me',
          primary: true,
          timeZone: 'Europe/Paris',
        }),
      ],
    ]);

    const actual = await calendarListRaw({});

    expect(actual).toEqual(
      [
        'me@example.com▮Me▮true▮Europe/Paris',
        'work@example.com▮Work▮false▮Europe/London',
      ].join('\n'),
    );
  });

  it('puts the Primary first, then the others by name', async () => {
    mockPages([
      [
        calendar('c', { summary: 'Charlie' }),
        calendar('a', { summary: 'alpha' }),
        calendar('me', { summary: 'Zed', primary: true }),
        calendar('b', { summary: 'Bravo' }),
      ],
    ]);

    const actual = await calendarListRaw({});

    expect(ids(actual)).toEqual(['me', 'a', 'b', 'c']);
  });

  it('shows the name set by the user, not the original one', async () => {
    mockPages([
      [calendar('a', { summary: 'Original', summaryOverride: 'Mine' })],
    ]);

    const actual = await calendarListRaw({});

    expect(actual.split('▮')[1]).toEqual('Mine');
  });

  it('marks only the Primary with true', async () => {
    mockPages([[calendar('a'), calendar('me', { primary: true })]]);

    const actual = await calendarListRaw({});

    const flags = actual.split('\n').map((line) => line.split('▮')[2]);
    expect(flags).toEqual(['true', 'false']);
  });

  it('removes the separators from the name', async () => {
    mockPages([[calendar('a', { summary: 'A▮B\nC' })]]);

    const actual = await calendarListRaw({});

    expect(actual).toEqual('a▮AB C▮false▮Europe/Paris');
  });

  it('limits the number of lines, after putting the Primary first', async () => {
    mockPages([
      [calendar('a'), calendar('b'), calendar('me', { primary: true })],
    ]);

    const actual = await calendarListRaw({ limit: 2 });

    expect(ids(actual)).toEqual(['me', 'a']);
  });

  it('limits to 25 lines by default', async () => {
    mockPages([Array.from({ length: 30 }, (_value, i) => calendar(`c${i}`))]);

    const actual = await calendarListRaw({});

    expect(actual.split('\n')).toHaveLength(25);
  });

  it('reads every page, so that the Primary is found on a later page', async () => {
    mockPages([
      [calendar('a')],
      [calendar('me', { primary: true }), calendar('b')],
    ]);

    const actual = await calendarListRaw({});

    expect(ids(actual)).toEqual(['me', 'a', 'b']);
  });

  it('prints an empty line when there is no Calendar', async () => {
    mockPages([[]]);

    const actual = await calendarListRaw({});

    expect(actual).toEqual('');
  });
});
