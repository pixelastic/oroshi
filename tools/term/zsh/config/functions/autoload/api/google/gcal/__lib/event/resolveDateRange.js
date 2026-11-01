import { _, dayjs } from 'golgoth';
import { firostError } from 'firost';
import { DATE_FORMAT } from './dateFormats.js';

export let __;

const DEFAULT_SPAN_IN_DAYS = 7;
const DAYS_IN_WEEK = 7;

/**
 * Resolve the period of the Events to list
 * @param {object} flags - Flags of the command
 * @param {string} [flags.dateMin] - First day of the period, as YYYY-MM-DD
 * @param {string} [flags.dateMax] - Last day of the period, as YYYY-MM-DD
 * @param {boolean} [flags.today] - Period of today only
 * @param {boolean} [flags.week] - Period of the current ISO week
 * @param {string} today - Date of today, as YYYY-MM-DD
 * @returns {{dateMin: string, dateMax: string}} First and last day of the period
 * @throws {Error} GCAL_DATE_INVALID on a date that is not a real YYYY-MM-DD, GCAL_DATE_RANGE_INVALID when the minimum is after the maximum
 */
export function resolveDateRange(flags, today) {
  const todayDate = dayjs(today);

  if (flags.today) {
    return {
      dateMin: todayDate.format(DATE_FORMAT),
      dateMax: todayDate.format(DATE_FORMAT),
    };
  }

  if (flags.week) {
    // dayjs counts Sunday as day 0, the ISO week starts on Monday
    const monday = todayDate.subtract(
      (todayDate.day() + DAYS_IN_WEEK - 1) % DAYS_IN_WEEK,
      'day',
    );
    return {
      dateMin: monday.format(DATE_FORMAT),
      dateMax: monday.add(DAYS_IN_WEEK - 1, 'day').format(DATE_FORMAT),
    };
  }

  const dateMin = __.parseDate(flags.dateMin);
  const dateMax = __.parseDate(flags.dateMax);

  // Only a maximum: the period is the 7 days before it
  const resolvedMin =
    dateMin ||
    (dateMax ? dateMax.subtract(DEFAULT_SPAN_IN_DAYS, 'day') : todayDate);
  const resolvedMax = dateMax || resolvedMin.add(DEFAULT_SPAN_IN_DAYS, 'day');

  if (resolvedMin.isAfter(resolvedMax)) {
    throw firostError(
      'GCAL_DATE_RANGE_INVALID',
      `--date-min ${resolvedMin.format(DATE_FORMAT)} is after --date-max ${resolvedMax.format(DATE_FORMAT)}`,
    );
  }

  return {
    dateMin: resolvedMin.format(DATE_FORMAT),
    dateMax: resolvedMax.format(DATE_FORMAT),
  };
}

__ = {
  /**
   * Parse a date given to a flag
   * @param {string} [value] - The date, as YYYY-MM-DD
   * @returns {import('dayjs').Dayjs|null} The date, or null when the flag is absent
   * @throws {Error} GCAL_DATE_INVALID when the value is not a real YYYY-MM-DD date
   */
  parseDate(value) {
    if (_.isUndefined(value)) {
      return null;
    }
    const date = dayjs(value);
    // A date that dayjs rolls over (2026-02-30) or reads loosely (02/11/2026) does not round-trip
    if (date.format(DATE_FORMAT) !== value) {
      throw firostError(
        'GCAL_DATE_INVALID',
        `"${value}" is not a date, use YYYY-MM-DD`,
      );
    }
    return date;
  },
};
