import { _, dayjs } from 'golgoth';
import { read } from 'firost';
import { callApi } from '../callApi.js';
import { API_TIME_FORMAT, DATE_FORMAT, TIME_FORMAT } from './dateFormats.js';
import { formatEvent } from './formatEvent.js';
import { fromApiDates } from './fromApiDates.js';
import { getEventPath } from './getEventPath.js';
import { getTimeZone } from './getTimeZone.js';
import { resolveVisibility } from './resolveVisibility.js';
import { toApiDates } from './toApiDates.js';

export let __;

/**
 * Update an Event. It never notifies the Attendees, and never changes them
 * @param {object} options - Fields to change. A field that is not passed stays untouched
 * @param {string} options.eventId - Id of the Event. Throws GCAL_EVENT_ID_MISSING if empty
 * @param {string} [options.title] - Title
 * @param {string} [options.dateStart] - Start, as YYYY-MM-DDTHH:MM (local to the Calendar) or YYYY-MM-DD for an All-day Event. Without dateEnd, the Event keeps its duration
 * @param {string} [options.dateEnd] - End, in the same format as the start. The last day of an All-day Event is included
 * @param {string} [options.location] - Location
 * @param {string} [options.description] - Description
 * @param {string} [options.descriptionFile] - Path of a file holding the description. It takes precedence over description
 * @param {boolean} [options.isPrivate] - Make the Event private
 * @param {boolean} [options.isPublic] - Give the Event the default visibility of the Calendar
 * @param {string} [options.calendarId] - Calendar of the Event, the Primary by default
 * @returns {Promise<object>} The updated Event, formatted by formatEvent
 * @throws {Error} GCAL_EVENT_ID_MISSING without an eventId, GCAL_VISIBILITY_CONFLICT when both isPrivate and isPublic are set, and the errors of toApiDates on a bad date
 */
export async function eventUpdate(options) {
  const {
    eventId,
    title,
    dateStart,
    dateEnd,
    location,
    descriptionFile,
    isPrivate,
    isPublic,
    calendarId = 'primary',
  } = options;

  const visibility = resolveVisibility({ isPrivate, isPublic });

  const eventPath = getEventPath(calendarId, eventId);
  const dates = await __.resolveDates({
    eventPath,
    calendarId,
    dateStart,
    dateEnd,
  });

  const description = descriptionFile
    ? await __.read(descriptionFile)
    : options.description;

  const response = await __.callApi(eventPath, {
    method: 'PATCH',
    query: { sendUpdates: 'none' },
    body: _.omitBy(
      {
        summary: title,
        ...__.clearOtherKind(dates),
        location,
        description,
        visibility,
      },
      _.isUndefined,
    ),
  });
  return __.formatEvent(response, calendarId);
}

__ = {
  /**
   * Convert the dates of the CLI into the start and end to patch. A start
   * without an end moves the Event and keeps its duration, as long as it stays
   * of the same kind (timed or All-day). An end without a start keeps the start
   * @param {object} options - Dates to resolve
   * @param {string} options.eventPath - Path of the Event in the API
   * @param {string} options.calendarId - Calendar of the Event
   * @param {string} [options.dateStart] - New start
   * @param {string} [options.dateEnd] - New end
   * @returns {Promise<object>} The start and end of the API, or an empty object when no date is passed
   * @throws {Error} The errors of toApiDates on a bad date
   */
  async resolveDates(options) {
    const { eventPath, calendarId, dateStart, dateEnd } = options;

    const hasDateStart = !_.isUndefined(dateStart);
    const hasDateEnd = !_.isUndefined(dateEnd);

    if (!hasDateStart && !hasDateEnd) {
      return {};
    }

    const timeZone = await __.getTimeZone(calendarId);
    if (hasDateStart && hasDateEnd) {
      return toApiDates({ dateStart, dateEnd, timeZone });
    }

    const currentEvent = await __.callApi(eventPath);
    if (!hasDateStart) {
      // The start of the Event is given without its offset
      const keptStart = _.truncate(
        fromApiDates(currentEvent.start, currentEvent.end).dateStart,
        {
          length: TIME_FORMAT.length,
          omission: '',
        },
      );
      return toApiDates({ dateStart: keptStart, dateEnd, timeZone });
    }

    const moved = toApiDates({ dateStart, timeZone });
    return __.keepDuration(moved, currentEvent);
  },

  /**
   * Move the end of an Event after its new start, by the same duration as
   * before. A new start of another kind (timed or All-day) keeps the default
   * end of toApiDates
   * @param {object} moved - New start and default end, as returned by toApiDates
   * @param {object} currentEvent - Start and end of the Event as the API gives them
   * @returns {object} The new start and end of the API
   */
  keepDuration(moved, currentEvent) {
    const isAllDay = _.has(moved.start, 'date');
    if (isAllDay !== _.has(currentEvent.start, 'date')) {
      return moved;
    }

    if (isAllDay) {
      const days = dayjs
        .utc(currentEvent.end.date)
        .diff(currentEvent.start.date, 'day');
      const date = dayjs.utc(moved.start.date).add(days, 'day');
      return { start: moved.start, end: { date: date.format(DATE_FORMAT) } };
    }

    const minutes = dayjs(currentEvent.end.dateTime).diff(
      currentEvent.start.dateTime,
      'minute',
    );
    const dateTime = dayjs.utc(moved.start.dateTime).add(minutes, 'minute');
    return {
      start: moved.start,
      end: {
        dateTime: dateTime.format(API_TIME_FORMAT),
        timeZone: moved.start.timeZone,
      },
    };
  },

  /**
   * Null the fields of the other kind (timed or All-day) in a start and an
   * end. The API merges a patched start into the current one, so a date next
   * to the old dateTime is refused
   * @param {object} dates - Start and end of the API, or an empty object
   * @returns {object} The same dates, with the fields of the other kind set to null
   */
  clearOtherKind(dates) {
    return _.mapValues(dates, (day) =>
      _.has(day, 'date')
        ? { ...day, dateTime: null, timeZone: null }
        : { ...day, date: null },
    );
  },

  callApi,
  formatEvent,
  getTimeZone,
  read,
};
