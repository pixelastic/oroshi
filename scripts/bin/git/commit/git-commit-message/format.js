import { _ } from 'golgoth';

/**
 * Formats a raw commit message from the API into a properly wrapped string.
 * Subject line is kept intact; body lines are wrapped at 72 characters.
 * @param {string} raw - Raw commit message string
 * @returns {string} Formatted commit message
 */
export function formatMessage(raw) {
  const lines = raw.split('\n');
  const blankIndex = lines.indexOf('');

  if (blankIndex === -1) {
    return lines.join(' ');
  }

  const subject = lines.slice(0, blankIndex).join(' ');
  const body = lines.slice(blankIndex + 1);

  return [subject, '', ...wrapLines(body)].join('\n');
}

/**
 * Re-flows an array of body lines, wrapping at maxLength characters.
 * Words are placed greedily; empty lines (paragraph breaks) are preserved.
 * @param {string[]} lines - Body lines to re-wrap
 * @param {number} maxLength - Maximum line length (default 72)
 * @returns {string[]} Re-wrapped lines
 */
export function wrapLines(lines, maxLength = 72) {
  const result = [];

  _.each(lines, (line) => {
    // Paragraph break — preserve and let next word start a new line
    if (line === '') {
      result.push('');
      return;
    }

    // Place each word onto the current line or start a new one
    _.each(line.split(' ').filter(Boolean), (word) => {
      const last = _.last(result);
      const wouldFit =
        last && last !== '' && `${last} ${word}`.length <= maxLength;
      if (wouldFit) {
        result[result.length - 1] = `${last} ${word}`;
      } else {
        result.push(word);
      }
    });
  });

  return result;
}
