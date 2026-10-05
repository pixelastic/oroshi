import path from 'node:path';
import { _, dayjs } from 'golgoth';
import { readJson } from 'firost';
import cliTruncate from 'cli-truncate';
import stringWidth from 'string-width';

export let __;

const UNREAD_ICON = 'gmail-unread';
const MARKER_WIDTH = 1;
const DATE_WIDTH = 11;
const AUTHORS_WIDTH = 28;
const SEPARATOR = '  ';
const AUTHORS_SEPARATOR = ', ';
const ELLIPSIS = '…';
const DATE_COLOR = 'gmail-date';
const AUTHORS_COLOR = 'gmail-author';
const SUBJECT_COLOR = 'gmail-subject';
const COLORS_RELATIVE_PATH = 'tools/term/zsh/config/theming/dist/colors.json';
const ICONS_RELATIVE_PATH = 'tools/term/zsh/config/theming/dist/icons.json';

/**
 * Format threads as a colored terminal table, one row per thread
 * @param {object[]} threads - Thread summaries { unread, date, count, authors, subject }, with date in ISO 8601
 * @param {object} options - Display options
 * @param {number} options.width - Terminal width, rows never exceed it
 * @returns {Promise<string>} Table, or a message if there are no mails
 */
export async function gmailFormat(threads, { width }) {
  if (_.isEmpty(threads)) {
    return 'No mails in the inbox.';
  }

  const colors = await __.readColors();
  const icons = await __.readIcons();
  const countWidth = _.chain(threads)
    .map('count')
    .max()
    .toString()
    .size()
    .value();
  const subjectWidth = Math.max(
    width -
      _.sum([MARKER_WIDTH, DATE_WIDTH, countWidth, AUTHORS_WIDTH]) -
      SEPARATOR.length * 4,
    0,
  );

  return _.chain(threads)
    .map((thread) =>
      _.trimEnd(
        [
          cell(thread.unread ? icons[UNREAD_ICON] : '', MARKER_WIDTH),
          cell(formatDate(thread.date), DATE_WIDTH, colors[DATE_COLOR]),
          cell(formatCount(thread.count), countWidth, colors[DATE_COLOR], {
            align: 'right',
          }),
          cell(
            _.join(thread.authors, AUTHORS_SEPARATOR),
            AUTHORS_WIDTH,
            colors[AUTHORS_COLOR],
          ),
          cell(thread.subject, subjectWidth, colors[SUBJECT_COLOR]),
        ].join(SEPARATOR),
      ),
    )
    .join('\n')
    .value();
}

__ = {
  /**
   * Read the design system color definitions
   * @returns {Promise<object>} Colors by name, each like { ansi, hex }
   */
  readColors() {
    return readJson(
      path.resolve(process.env.OROSHI_ROOT, COLORS_RELATIVE_PATH),
    );
  },
  /**
   * Read the design system icon definitions
   * @returns {Promise<object>} Icons by name
   */
  readIcons() {
    return readJson(path.resolve(process.env.OROSHI_ROOT, ICONS_RELATIVE_PATH));
  },
};

/**
 * Collapse all whitespace, including newlines, into single spaces
 * @param {string} text - Text to flatten
 * @returns {string} Single-line text
 */
function oneLine(text) {
  return _.chain(text).replace(/\s+/g, ' ').trim().value();
}

/**
 * Truncate, color then pad text to a fixed column width. Widths are display
 * widths, so wide and combining characters stay aligned. The padding stays
 * outside of the color so trailing spaces can be trimmed
 * @param {string} text - Cell content
 * @param {number} size - Column width
 * @param {object} [color] - Color definition { ansi }
 * @param {object} [options] - Cell options
 * @param {string} [options.align] - "left" or "right"
 * @returns {string} Cell of `size` visible columns
 */
function cell(text, size, color, { align = 'left' } = {}) {
  const truncated = cliTruncate(oneLine(text), size, {
    truncationCharacter: ELLIPSIS,
  });
  const padding = _.repeat(' ', size - stringWidth(truncated));
  const colored =
    _.isUndefined(color) || truncated === ''
      ? truncated
      : `\u001B[38;5;${color.ansi}m${truncated}\u001B[0m`;
  return align === 'right' ? `${padding}${colored}` : `${colored}${padding}`;
}

/**
 * Format an ISO 8601 date as a short local date
 * @param {string} date - ISO 8601 date
 * @returns {string} `MM/DD HH:mm`, or an empty string if invalid
 */
function formatDate(date) {
  const parsed = dayjs(date);
  return parsed.isValid() ? parsed.format('MM/DD HH:mm') : '';
}

/**
 * Format a message count, blank for a single message
 * @param {number} count - Number of messages in the thread
 * @returns {string} The count, or an empty string for a single message
 */
function formatCount(count) {
  return count > 1 ? String(count) : '';
}
