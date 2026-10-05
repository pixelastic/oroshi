import path from 'node:path';
import { _, dayjs } from 'golgoth';
import { readJson } from 'firost';
import cliTruncate from 'cli-truncate';
import stringWidth from 'string-width';
import { gmailSenderName } from './senderName.js';

export let __;

const DATE_WIDTH = 11;
const SENDER_WIDTH = 28;
const SEPARATOR = '  ';
const ELLIPSIS = '…';
const DATE_COLOR = 'gmail-date';
const SENDER_COLOR = 'gmail-author';
const SUBJECT_COLOR = 'gmail-subject';
const COLORS_RELATIVE_PATH = 'tools/term/zsh/config/theming/dist/colors.json';

/**
 * Format messages as a colored terminal table, one row per message
 * @param {object[]} messages - Normalized messages { from, subject, date }
 * @param {object} options - Display options
 * @param {number} options.width - Terminal width, rows never exceed it
 * @returns {Promise<string>} Table, or a message if there are no mails
 */
export async function gmailFormat(messages, { width }) {
  if (_.isEmpty(messages)) {
    return 'No mails in the inbox.';
  }

  const colors = await __.readColors();
  const subjectWidth = Math.max(
    width - DATE_WIDTH - SEPARATOR.length - SENDER_WIDTH - SEPARATOR.length,
    0,
  );

  return _.chain(messages)
    .map((message) =>
      _.trimEnd(
        [
          cell(formatDate(message.date), DATE_WIDTH, colors[DATE_COLOR]),
          cell(
            gmailSenderName(message.from),
            SENDER_WIDTH,
            colors[SENDER_COLOR],
          ),
          cell(message.subject, subjectWidth, colors[SUBJECT_COLOR]),
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
 * @returns {string} Cell of `size` visible columns
 */
function cell(text, size, color) {
  const truncated = cliTruncate(oneLine(text), size, {
    truncationCharacter: ELLIPSIS,
  });
  const padding = _.repeat(' ', size - stringWidth(truncated));
  if (_.isUndefined(color) || truncated === '') {
    return `${truncated}${padding}`;
  }
  return `\u001B[38;5;${color.ansi}m${truncated}\u001B[0m${padding}`;
}

/**
 * Format a Date header as a short local date
 * @param {string} date - Date header
 * @returns {string} `MM/DD HH:mm`, or an empty string if invalid
 */
function formatDate(date) {
  const parsed = dayjs(date);
  return parsed.isValid() ? parsed.format('MM/DD HH:mm') : '';
}
