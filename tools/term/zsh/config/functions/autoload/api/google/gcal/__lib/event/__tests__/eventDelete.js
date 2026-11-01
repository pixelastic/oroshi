import { firostError } from 'firost';
import { __, eventDelete } from '../eventDelete.js';

describe('eventDelete', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue('');
  });

  it.each([
    {
      title: 'deletes the Event of the Primary by default',
      input: { eventId: 'a' },
      expected: 'calendars/primary/events/a',
    },
    {
      title: 'deletes the Event of the Calendar given with --calendarId',
      input: { eventId: 'a', calendarId: 'work@group.calendar.google.com' },
      expected: 'calendars/work%40group.calendar.google.com/events/a',
    },
    {
      title: 'encodes the eventId in the path',
      input: { eventId: 'a/b' },
      expected: 'calendars/primary/events/a%2Fb',
    },
  ])('$title', async ({ input, expected }) => {
    await eventDelete(input);

    expect(__.callApi).toHaveBeenCalledWith(expected, {
      method: 'DELETE',
      query: { sendUpdates: 'none' },
    });
  });

  it('returns the eventId', async () => {
    const actual = await eventDelete({ eventId: 'a' });

    expect(actual).toEqual('a');
  });

  it('throws when the eventId is missing', async () => {
    let actual = null;
    try {
      await eventDelete({ eventId: '' });
    } catch (err) {
      actual = err;
    }

    expect(actual).toHaveProperty('code', 'GCAL_EVENT_ID_MISSING');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it.each([
    { title: 'an unknown Event', status: '404' },
    { title: 'an Event already deleted', status: '410' },
  ])('throws GCAL_EVENT_NOT_FOUND for $title', async ({ status }) => {
    __.callApi.mockImplementation(() => {
      throw firostError('GCAL_REQUEST_FAILED', `${status} {"error":"gone"}`);
    });

    let actual = null;
    try {
      await eventDelete({ eventId: 'a' });
    } catch (err) {
      actual = err;
    }

    expect(actual).toHaveProperty('code', 'GCAL_EVENT_NOT_FOUND');
    expect(actual).toHaveProperty('message', 'Event a not found');
  });

  it('rethrows any other error of the API', async () => {
    __.callApi.mockImplementation(() => {
      throw firostError('GCAL_REQUEST_FAILED', '500 oops');
    });

    let actual = null;
    try {
      await eventDelete({ eventId: 'a' });
    } catch (err) {
      actual = err;
    }

    expect(actual).toHaveProperty('code', 'GCAL_REQUEST_FAILED');
  });
});
