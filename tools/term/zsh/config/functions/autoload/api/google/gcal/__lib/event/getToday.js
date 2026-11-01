import { dayjs } from 'golgoth';

/**
 * Get the date of today
 * @returns {string} Today, as YYYY-MM-DD
 */
export function getToday() {
  return dayjs().format('YYYY-MM-DD');
}
