import { _ } from 'golgoth';

export let __;

const PRIORITY = { '~': 3, '+': 2, '-': 1 };

/**
 * Classify new-side lines as +, ~, -, or context from hunkdiff changes
 * @param {Array<{hunkIndex: number, kind: string, range: [number, number]}>} changes - Change ranges
 * @param {number} totalLines - Number of lines in the new-side document
 * @returns {Map<number, {marker: string, hunkIndex: number}>} Line classifications
 */
export function classifyLines(changes, totalLines) {
  const result = new Map();
  const hunks = __.groupByHunk(changes);

  _.each(hunks, (hunkChanges, hunkIndex) => {
    const added = _.filter(hunkChanges, { kind: 'added' });
    const removed = _.filter(hunkChanges, { kind: 'removed' });

    // Classify added ranges
    _.each(added, (addedChange) => {
      const isModified = _.some(
        removed,
        (removedChange) => removedChange.range[1] >= addedChange.range[0] - 1,
      );
      const marker = isModified ? '~' : '+';
      __.applyRange(result, addedChange.range, marker, Number(hunkIndex));
    });

    // Classify orphan removed ranges (no adjacent added)
    _.each(removed, (removedChange) => {
      const hasAdjacentAdded = _.some(
        added,
        (addedChange) => removedChange.range[1] >= addedChange.range[0] - 1,
      );
      if (hasAdjacentAdded) return;

      const targetLine = removedChange.range[0];
      if (targetLine > totalLines) return;

      __.applyMarker(result, targetLine, '-', Number(hunkIndex));
    });
  });

  return result;
}

__ = {
  /**
   * Group changes by hunkIndex
   * @param {Array<{hunkIndex: number, kind: string, range: [number, number]}>} changes - Change ranges
   * @returns {object} Changes grouped by hunkIndex
   */
  groupByHunk(changes) {
    return _.groupBy(changes, 'hunkIndex');
  },

  /**
   * Apply a marker to all lines in a range
   * @param {Map} result - Result map
   * @param {[number, number]} range - Line range [start, end]
   * @param {string} marker - Marker type
   * @param {number} hunkIndex - Hunk index
   */
  applyRange(result, range, marker, hunkIndex) {
    _.each(_.range(range[0], range[1] + 1), (line) => {
      __.applyMarker(result, line, marker, hunkIndex);
    });
  },

  /**
   * Apply a marker to a single line, respecting priority
   * @param {Map} result - Result map
   * @param {number} line - Line number
   * @param {string} marker - Marker type
   * @param {number} hunkIndex - Hunk index
   */
  applyMarker(result, line, marker, hunkIndex) {
    const existing = result.get(line);
    if (existing && PRIORITY[existing.marker] >= PRIORITY[marker]) return;

    result.set(line, { marker, hunkIndex });
  },
};
