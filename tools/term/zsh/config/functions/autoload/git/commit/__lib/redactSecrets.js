const SECRET_MIN_LENGTH = 32;
const REDACT_FILL = 'REDACTED_';

// Matches long runs of word chars + hyphens (the shape of API keys / tokens)
const SECRET_PATTERN = new RegExp(`[a-zA-Z0-9_-]{${SECRET_MIN_LENGTH},}`, 'g');

/**
 * Lines that are diff metadata — never redact tokens on these.
 * @param {string} line - Diff line to check
 * @returns {boolean} True if the line is diff metadata
 */
function isDiffMeta(line) {
  return (
    line.startsWith('diff --git ') ||
    line.startsWith('--- ') ||
    line.startsWith('+++ ') ||
    line.startsWith('@@') ||
    line.startsWith('index ')
  );
}

/**
 * Build a redacted replacement string of the given length.
 * @param {number} length - Desired length of the replacement
 * @returns {string} Repeating REDACTED_ fill truncated to length
 */
function buildRedacted(length) {
  return REDACT_FILL.repeat(Math.ceil(length / REDACT_FILL.length)).slice(
    0,
    length,
  );
}

/**
 * Redacts long secret-looking strings in a git diff.
 * Preserves diff structure (headers, filenames, line numbers, context).
 * @param {string} diff - Raw diff string
 * @returns {string} Diff with secrets replaced by REDACTED_ fill
 */
export function redactSecrets(diff) {
  if (!diff) {
    return diff;
  }

  return diff
    .split('\n')
    .map((line) => {
      if (isDiffMeta(line)) {
        return line;
      }
      return line.replace(SECRET_PATTERN, (match) =>
        buildRedacted(match.length),
      );
    })
    .join('\n');
}
