import { firostError } from 'firost';

const DURATION_PATTERN = /^(\d+)([mhd])$/;
const UNIT_IN_MS = { m: 60_000, h: 3_600_000, d: 86_400_000 };

/**
 * Convert a --since value into the date to stop at
 * Accepts a duration back from now (30m, 12h, 5d) or a date (2026-10-20,
 * 2026-10-20T08:00:00Z).
 * @param {string} input - Duration or date
 * @param {object} [options] - Options
 * @param {Date} [options.now] - Reference date for durations
 * @returns {Date} The date to stop at
 */
export function parseSince(input, { now = new Date() } = {}) {
  const duration = DURATION_PATTERN.exec(input);
  if (duration) {
    const [, amount, unit] = duration;
    return new Date(now.getTime() - Number(amount) * UNIT_IN_MS[unit]);
  }

  const date = new Date(input);
  if (input === '' || Number.isNaN(date.getTime())) {
    throw firostError(
      'VINTED_LABEL_INVALID_SINCE',
      `--since expects a duration like 5d, 12h, 30m or a date, got "${input}"`,
    );
  }
  return date;
}
