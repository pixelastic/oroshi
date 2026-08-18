import { _ } from 'golgoth';
// eslint-disable-next-line import/no-unresolved -- provided by hunkdiff at runtime
import React from 'react';
import { classifyLines } from './lib/classify.js';
import { buildLayout } from './lib/layout.js';

export let __;

/**
 * Added-only file view extension factory
 * Replaces the default unified diff with a new-side-only view
 * @param {object} hunk - HunkExtensionAPI
 */
export default function addedOnly(hunk) {
  const colors = {
    colorAdded: hunk.config.colorAdded,
    colorModified: hunk.config.colorModified,
    colorRemoved: hunk.config.colorRemoved,
  };

  hunk.registerFileView({
    id: 'added-only',
    title: 'Added Only',
    matches: () => true,
    layout: (input) => __.layout(input, colors),
  });
}

__ = {
  /**
   * Build the full file view layout from input
   * @param {object} input - ExtensionFileViewInput
   * @param {object} colors - { colorAdded, colorModified, colorRemoved }
   * @returns {object|null} ExtensionFileViewLayout or null
   */
  async layout(input, colors) {
    const doc = await input.readDocument('new');
    if (!doc) return null;

    const lines = doc.split('\n');
    const annotations = __.classifyLines(input.changes, lines.length);
    if (annotations.size === 0) return { rows: [], hunkRows: [] };

    const descriptors = __.buildLayout(lines, annotations);
    const maxLineNumber = __.maxLineNumber(descriptors);
    const rows = __.toRows(descriptors, colors, maxLineNumber);
    const hunkRows = __.computeHunkRows(descriptors, annotations);

    return { rows, hunkRows };
  },

  /**
   * Classify new-side lines from change ranges
   * @param {Array} changes - Change ranges from input
   * @param {number} totalLines - Total lines in document
   * @returns {Map} Line classifications
   */
  classifyLines(changes, totalLines) {
    return classifyLines(changes, totalLines);
  },

  /**
   * Build row descriptors from lines and annotations
   * @param {string[]} lines - Document lines
   * @param {Map} annotations - Line classifications
   * @returns {Array} Row descriptors
   */
  buildLayout(lines, annotations) {
    return buildLayout(lines, annotations);
  },

  /**
   * Find the maximum line number across all line descriptors
   * @param {Array} descriptors - Row descriptors
   * @returns {number} Largest line number
   */
  maxLineNumber(descriptors) {
    let max = 0;
    _.each(descriptors, (d) => {
      if (d.type === 'line' && d.lineNumber > max) max = d.lineNumber;
    });
    return max;
  },

  /**
   * Convert row descriptors to ExtensionFileViewRow objects
   * @param {Array} descriptors - Row descriptors from buildLayout
   * @param {object} colors - Hex color config
   * @param {number} maxLineNumber - Largest line number for padding
   * @returns {Array} ExtensionFileViewRow[]
   */
  toRows(descriptors, colors, maxLineNumber) {
    const padWidth = String(maxLineNumber).length;

    return _.map(descriptors, (descriptor, index) => {
      if (descriptor.type === 'separator') {
        return {
          id: `separator-${index}`,
          spans: [{ text: '···', tone: 'muted' }],
        };
      }

      const { lineNumber, marker, content } = descriptor;
      const paddedNum = String(lineNumber).padStart(padWidth) + ' ';

      return {
        id: `line-${lineNumber}`,
        spans: __.lineSpans(marker, paddedNum, content),
        sourceRanges: [{ side: 'new', range: [lineNumber, lineNumber] }],
        component: {
          height: 1,
          render: __.makeRender(
            marker,
            paddedNum,
            content,
            __.markerColor(marker, colors),
          ),
        },
      };
    });
  },

  /**
   * Build fallback spans for a line row
   * @param {string|null} marker - Gutter marker or null for context
   * @param {string} paddedNum - Right-aligned padded line number with trailing space
   * @param {string} content - Line text
   * @returns {Array} ExtensionFileViewSpan[]
   */
  lineSpans(marker, paddedNum, content) {
    const markerSpan = marker
      ? { text: `${marker} `, tone: __.markerTone(marker) }
      : { text: '  ' };

    return [markerSpan, { text: paddedNum, tone: 'muted' }, { text: content }];
  },

  /**
   * Map marker to fallback tone
   * @param {string} marker - +, ~, or -
   * @returns {string} Tone name
   */
  markerTone(marker) {
    if (marker === '-') return 'removed';
    return 'added';
  },

  /**
   * Map marker to configured hex color
   * @param {string|null} marker - Gutter marker
   * @param {object} colors - Color config
   * @returns {string|null} Hex color or null
   */
  markerColor(marker, colors) {
    if (marker === '+') return colors.colorAdded;
    if (marker === '~') return colors.colorModified;
    if (marker === '-') return colors.colorRemoved;
    return null;
  },

  /**
   * Create a render function for a line row component
   * @param {string|null} marker - Gutter marker
   * @param {string} paddedNum - Padded line number
   * @param {string} content - Line text
   * @param {string|null} color - Hex color for marker
   * @returns {Function} Component render function
   */
  makeRender(marker, paddedNum, content, color) {
    return (props) => {
      const gutterText = marker ? `${marker} ` : '  ';
      const gutterProps = color ? { fg: color } : {};

      return React.createElement(
        'text',
        null,
        React.createElement('span', gutterProps, gutterText),
        React.createElement('span', { fg: props.theme.muted }, paddedNum),
        React.createElement('span', null, content),
      );
    };
  },

  /**
   * Compute hunkRows mapping from descriptors and annotations
   * @param {Array} descriptors - Row descriptors
   * @param {Map} annotations - Line classifications with hunkIndex
   * @returns {Array} { startRow, endRow }[] ordered by hunk index
   */
  computeHunkRows(descriptors, annotations) {
    // Assign each row a hunkIndex
    const rowHunks = __.assignRowHunks(descriptors, annotations);

    // Group by hunkIndex and find min/max row indices
    const hunkMap = new Map();
    _.each(rowHunks, (hunkIndex, rowIndex) => {
      if (hunkIndex === null) return;
      if (!hunkMap.has(hunkIndex)) {
        hunkMap.set(hunkIndex, { startRow: rowIndex, endRow: rowIndex });
      } else {
        const entry = hunkMap.get(hunkIndex);
        entry.endRow = rowIndex;
      }
    });

    // Return ordered by hunk index
    return _.chain([...hunkMap.entries()])
      .sortBy(([index]) => index)
      .map(([, range]) => range)
      .value();
  },

  /**
   * Assign a hunkIndex to each row
   * Annotated lines get their hunkIndex, context lines inherit from nearest annotated neighbor,
   * separators get null
   * @param {Array} descriptors - Row descriptors
   * @param {Map} annotations - Line classifications
   * @returns {Array} hunkIndex per row (null for separators)
   */
  assignRowHunks(descriptors, annotations) {
    const result = _.map(descriptors, (d) => {
      if (d.type === 'separator') return null;
      const annotation = annotations.get(d.lineNumber);
      return annotation ? annotation.hunkIndex : undefined;
    });

    // Forward pass: context rows after an annotated row inherit its hunkIndex
    let lastHunk = undefined;
    _.each(result, (hunk, i) => {
      if (result[i] === null) {
        lastHunk = undefined;
        return;
      }
      if (result[i] !== undefined) {
        lastHunk = result[i];
      } else if (lastHunk !== undefined) {
        result[i] = lastHunk;
      }
    });

    // Backward pass: context rows before the first annotated row in a block
    lastHunk = undefined;
    _.eachRight(result, (hunk, i) => {
      if (result[i] === null) {
        lastHunk = undefined;
        return;
      }
      if (result[i] !== undefined) {
        lastHunk = result[i];
      } else if (lastHunk !== undefined) {
        result[i] = lastHunk;
      }
    });

    return result;
  },
};
