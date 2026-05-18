#!/usr/bin/env node
import { _ } from 'golgoth';

export let __;

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

  const wrappedBody = _.chain(body)
    .map((line) => (line.length <= 72 ? [line] : __.wrapLine(line)))
    .flatten()
    .value();

  return [subject, '', ...wrappedBody].join('\n');
}

__ = {
  /**
   * Wraps a single line at 72 characters on word boundaries.
   * @param {string} line - Line to wrap
   * @returns {string[]} Array of wrapped lines
   */
  wrapLine(line) {
    return _.reduce(
      line.split(' '),
      (acc, word) => {
        const last = _.last(acc);
        if (!last || `${last} ${word}`.length > 72) return [...acc, word];
        return [..._.initial(acc), `${last} ${word}`];
      },
      [],
    );
  },
};
