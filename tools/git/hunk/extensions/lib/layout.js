import _ from '/home/tim/.oroshi/node_modules/golgoth/lodash.js';

export let __;

/**
 * Build row descriptors from document lines and classification annotations
 * @param {string[]} lines - New-side document lines
 * @param {Map<number, {marker: string, hunkIndex: number}>} annotations - Line classifications
 * @param {number} [contextSize=3] - Context lines around each changed range
 * @returns {Array<{type: string, lineNumber?: number, marker?: string|null, content?: string}>} Row descriptors
 */
export function buildLayout(lines, annotations, contextSize = 3) {
  if (annotations.size === 0) return [];

  const ranges = __.buildRanges(annotations, contextSize, lines.length);
  const merged = __.mergeRanges(ranges);

  return __.emitRows(merged, annotations, lines);
}

__ = {
  /**
   * Expand annotated lines into context ranges, clamped to document bounds
   * @param {Map} annotations - Line classifications
   * @param {number} contextSize - Context padding
   * @param {number} totalLines - Document length
   * @returns {Array<[number, number]>} Sorted expanded ranges
   */
  buildRanges(annotations, contextSize, totalLines) {
    const ranges = [];
    _.each(
      [...annotations.keys()].sort((a, b) => a - b),
      (line) => {
        const start = Math.max(1, line - contextSize);
        const end = Math.min(totalLines, line + contextSize);
        ranges.push([start, end]);
      },
    );
    return ranges;
  },

  /**
   * Merge overlapping or adjacent ranges
   * @param {Array<[number, number]>} ranges - Sorted ranges
   * @returns {Array<[number, number]>} Merged ranges
   */
  mergeRanges(ranges) {
    if (ranges.length === 0) return [];

    const merged = [ranges[0]];
    _.each(_.tail(ranges), (range) => {
      const last = merged[merged.length - 1];
      if (range[0] <= last[1] + 1) {
        last[1] = Math.max(last[1], range[1]);
      } else {
        merged.push(range);
      }
    });
    return merged;
  },

  /**
   * Emit row descriptors from merged ranges
   * @param {Array<[number, number]>} merged - Merged ranges
   * @param {Map} annotations - Line classifications
   * @param {string[]} lines - Document lines
   * @returns {Array} Row descriptors
   */
  emitRows(merged, annotations, lines) {
    const rows = [];
    _.each(merged, (range, index) => {
      if (index > 0) rows.push({ type: 'separator' });
      _.each(_.range(range[0], range[1] + 1), (lineNumber) => {
        const annotation = annotations.get(lineNumber);
        rows.push({
          type: 'line',
          lineNumber,
          marker: annotation ? annotation.marker : null,
          content: lines[lineNumber - 1],
        });
      });
    });
    return rows;
  },
};
