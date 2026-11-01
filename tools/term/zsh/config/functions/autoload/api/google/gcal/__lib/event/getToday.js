import { dayjs } from 'golgoth';
import { DATE_FORMAT } from './dateFormats.js';

/**
 * Get the date of today
 * @returns {string} Today, as YYYY-MM-DD
 */
export function getToday() {
  return dayjs().format(DATE_FORMAT);
}
