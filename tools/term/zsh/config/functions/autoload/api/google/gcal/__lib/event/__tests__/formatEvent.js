import { formatEvent } from '../formatEvent.js';

describe('formatEvent', () => {
  /**
   * Build a timed Event, as returned by the API
   * @param {object} fields - Fields to override
   * @returns {object} Event
   */
  function event(fields = {}) {
    return {
      id: 'a',
      status: 'confirmed',
      summary: 'Stand-up',
      htmlLink: 'https://www.google.com/calendar/event?eid=abc',
      organizer: { email: 'boss@algolia.com', self: true },
      start: {
        dateTime: '2026-11-02T10:00:00+01:00',
        timeZone: 'Europe/Paris',
      },
      end: { dateTime: '2026-11-02T11:00:00+01:00', timeZone: 'Europe/Paris' },
      ...fields,
    };
  }

  it('returns the fields of the output JSON, and only them', () => {
    const response = event({
      location: 'Room 1',
      description: 'Daily sync',
      attendees: [
        {
          email: 'boss@algolia.com',
          responseStatus: 'accepted',
          self: true,
          organizer: true,
        },
      ],
      creator: { email: 'boss@algolia.com' },
      iCalUID: 'abc@google.com',
    });

    const actual = formatEvent(response, 'work@group.calendar.google.com');

    expect(actual).toEqual({
      eventId: 'a',
      calendarId: 'work@group.calendar.google.com',
      title: 'Stand-up',
      status: 'confirmed',
      dateStart: '2026-11-02T10:00:00+01:00',
      dateEnd: '2026-11-02T11:00:00+01:00',
      isAllDay: false,
      location: 'Room 1',
      description: 'Daily sync',
      url: 'https://www.google.com/calendar/event?eid=abc',
      organizer: 'boss@algolia.com',
      attendees: [{ email: 'boss@algolia.com', responseStatus: 'accepted' }],
    });
  });

  describe('attendees', () => {
    it('keeps only the email and the responseStatus of each Attendee', () => {
      const response = event({
        attendees: [
          { email: 'a@y.z', responseStatus: 'accepted', displayName: 'A' },
          { email: 'b@y.z', responseStatus: 'needsAction', optional: true },
        ],
      });

      const actual = formatEvent(response, 'primary');

      expect(actual).toHaveProperty('attendees', [
        { email: 'a@y.z', responseStatus: 'accepted' },
        { email: 'b@y.z', responseStatus: 'needsAction' },
      ]);
    });

    it('is an empty array for an Event without Attendees', () => {
      const actual = formatEvent(event(), 'primary');

      expect(actual).toHaveProperty('attendees', []);
    });

    it('has no attendeeCount', () => {
      const actual = formatEvent(event(), 'primary');

      expect(actual).not.toHaveProperty('attendeeCount');
    });
  });

  describe('absent fields', () => {
    it.each([
      { field: 'location' },
      { field: 'description' },
      { field: 'title', source: 'summary' },
      { field: 'organizer' },
    ])('is an empty string when $field is absent', ({ field, source }) => {
      const response = event({ [source || field]: undefined });

      const actual = formatEvent(response, 'primary');

      expect(actual).toHaveProperty(field, '');
    });
  });

  describe('dates', () => {
    it('keeps the time and its offset for a timed Event', () => {
      const actual = formatEvent(event(), 'primary');

      expect(actual).toMatchObject({
        dateStart: '2026-11-02T10:00:00+01:00',
        dateEnd: '2026-11-02T11:00:00+01:00',
        isAllDay: false,
      });
    });

    it('marks an All-day Event and makes its end inclusive', () => {
      const response = event({
        start: { date: '2026-11-02' },
        end: { date: '2026-11-03' },
      });

      const actual = formatEvent(response, 'primary');

      expect(actual).toMatchObject({
        dateStart: '2026-11-02',
        dateEnd: '2026-11-02',
        isAllDay: true,
      });
    });

    it('keeps the last day of an All-day Event of several days', () => {
      const response = event({
        start: { date: '2026-12-30' },
        end: { date: '2027-01-02' },
      });

      const actual = formatEvent(response, 'primary');

      expect(actual).toHaveProperty('dateEnd', '2027-01-01');
    });
  });

  it('does not change the response it receives', () => {
    const response = event({
      start: { date: '2026-11-02' },
      end: { date: '2026-11-03' },
    });

    formatEvent(response, 'primary');

    expect(response).toHaveProperty('end', { date: '2026-11-03' });
  });
});
