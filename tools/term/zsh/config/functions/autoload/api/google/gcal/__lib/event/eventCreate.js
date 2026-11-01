import { _ } from 'golgoth';
import { firostError, read } from 'firost';
import { callApi } from '../callApi.js';
import { formatEvent } from './formatEvent.js';
import { getEventsPath } from './getEventsPath.js';
import { getTimeZone } from './getTimeZone.js';
import { resolveVisibility } from './resolveVisibility.js';
import { toApiDates } from './toApiDates.js';

export let __;

/**
 * Create an Event. It never notifies the Attendees
 * @param {object} options - Fields of the Event
 * @param {string} options.title - Title. Throws GCAL_TITLE_MISSING if empty
 * @param {string} options.dateStart - Start, as YYYY-MM-DDTHH:MM (local to the Calendar) or YYYY-MM-DD for an All-day Event
 * @param {string} [options.dateEnd] - End, in the same format as the start. The last day of an All-day Event is included. One hour (or one day) after the start by default
 * @param {string} [options.location] - Location
 * @param {string} [options.description] - Description
 * @param {string} [options.descriptionFile] - Path of a file holding the description. It takes precedence over description
 * @param {string} [options.attendees] - E-mail addresses of the initial Attendees, separated by commas
 * @param {boolean} [options.isPrivate] - Make the Event private
 * @param {boolean} [options.isPublic] - Give the Event the default visibility of the Calendar
 * @param {string} [options.calendarId] - Calendar of the Event, the Primary by default
 * @returns {Promise<object>} The created Event, formatted by formatEvent
 * @throws {Error} GCAL_TITLE_MISSING without a title, GCAL_VISIBILITY_CONFLICT when both isPrivate and isPublic are set, and the errors of toApiDates on a bad date
 */
export async function eventCreate(options) {
  const {
    title,
    dateStart,
    dateEnd,
    location,
    descriptionFile,
    attendees,
    isPrivate,
    isPublic,
    calendarId = 'primary',
  } = options;

  if (!title) {
    throw firostError('GCAL_TITLE_MISSING', 'Pass the title with --title');
  }

  const visibility = resolveVisibility({ isPrivate, isPublic });

  // The time is local to the Calendar, so its time zone comes first
  const timeZone = await __.getTimeZone(calendarId);
  const dates = toApiDates({ dateStart, dateEnd, timeZone });

  const description = descriptionFile
    ? await __.read(descriptionFile)
    : options.description;

  const response = await __.callApi(getEventsPath(calendarId), {
    method: 'POST',
    query: { sendUpdates: 'none' },
    body: _.omitBy(
      {
        summary: title,
        ...dates,
        location,
        description,
        visibility,
        attendees: attendees && __.parseAttendees(attendees),
      },
      _.isUndefined,
    ),
  });
  return __.formatEvent(response, calendarId);
}

__ = {
  /**
   * Turn a list of e-mail addresses into the Attendees of the API
   * @param {string} attendees - E-mail addresses, separated by commas
   * @returns {object[]} The Attendees, as { email }
   */
  parseAttendees(attendees) {
    return _.chain(attendees)
      .split(',')
      .map(_.trim)
      .compact()
      .map((email) => ({ email }))
      .value();
  },

  callApi,
  formatEvent,
  getTimeZone,
  read,
};
