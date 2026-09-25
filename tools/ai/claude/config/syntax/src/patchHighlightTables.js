import { _ } from 'golgoth';
import { firostError } from 'firost';

// Diff/file preview table (Monokai Extended), immediately followed by the
// light (GitHub) table whose first entry is keyword:rgb(167,29,93)
const DIFF_TABLE_REGEXP =
  /new Map\((?:\[\["keyword",|Object\.entries\(\{keyword:)[^;]*?\)\s*(?=,[\w$]+=new Map\(\[\["keyword",([\w$]+)\(167,29,93\)\])/;
const DIFF_ENTRY_REGEXP =
  /(?:\["([^"]+)",|"([^"]+)":|([\w$]+):)([\w$]+\(\d+,\d+,\d+\))/g;

// Markdown code block table (chalk), immediately followed by the scope lookup
const CODE_TABLE_REGEXP =
  /new Map\(Object\.entries\(\{keyword:[^;]*?\)\)\s*(?=;function [\w$]+\(e\)\{let t=e\.replace\(\/\^hljs-\/)/;
const CODE_ENTRY_REGEXP =
  /(?:"([^"]+)"|([\w$-]+)):("[0-9a-f]{6}"|[\w$]+(?:\.[\w$]+)+)/g;

// Dark theme diff line number and +/- marker colors, identified by the
// foreground, deleteLine and deleteWord colors declared just before them
const DECORATION_TABLE_REGEXP =
  /let [\w$]+=([\w$]+)\(248,248,242\),[\w$]+=\1\(61,1,0\),[\w$]+=\1\(92,2,0\),[\w$]+=\1\(\d+,\d+,\d+ *\);if\([\w$]+\)return\{[^}]*\};return\{[^}]*?addDecoration:\1\(\d+,\d+,\d+ *\)/;

export let __;

/**
 * Replace Claude Code syntax highlighting tables with the given colors.
 * The output has the exact same length as the input, so it can be written
 * back into the binary without moving any offset.
 * @param {string} text - Binary content, as a latin1 string
 * @param {object} scopeColors - Map of highlight.js scope → '#rrggbb'
 * @param {object} [decorationColors] - Diff line number and marker colors
 * @param {string} [decorationColors.added] - '#rrggbb' of added lines
 * @param {string} [decorationColors.removed] - '#rrggbb' of removed lines
 * @returns {{text: string, offsets: number[]}} Patched text and offset of each patched table
 */
export function patchHighlightTables(text, scopeColors, decorationColors = {}) {
  const tables = [
    {
      name: 'diff',
      regexp: DIFF_TABLE_REGEXP,
      build: __.buildDiffTable,
    },
    {
      name: 'code block',
      regexp: CODE_TABLE_REGEXP,
      build: __.buildCodeTable,
    },
    {
      name: 'diff decoration',
      regexp: DECORATION_TABLE_REGEXP,
      build: (match) => __.buildDecorationTable(match, decorationColors),
    },
  ];

  let patchedText = text;
  const offsets = _.map(tables, ({ name, regexp, build }) => {
    const match = patchedText.match(regexp);
    if (!match) {
      throw firostError(
        'CLAUDE_SYNTAX_PATCH_TABLE_NOT_FOUND',
        `Could not find the ${name} syntax highlighting table`,
      );
    }

    const original = match[0];
    const replacement = build(match, scopeColors);
    if (replacement.length > original.length) {
      throw firostError(
        'CLAUDE_SYNTAX_PATCH_TOO_LONG',
        `Patched ${name} table is ${replacement.length - original.length} chars too long`,
      );
    }

    patchedText =
      patchedText.slice(0, match.index) +
      replacement.padEnd(original.length, ' ') +
      patchedText.slice(match.index + original.length);
    return match.index;
  });

  return { text: patchedText, offsets };
}

__ = {
  /**
   * Build the diff table, as rgb values passed to the color function
   * @param {Array} match - DIFF_TABLE_REGEXP match
   * @param {object} scopeColors - Map of scope → '#rrggbb'
   * @returns {string} Replacement table
   */
  buildDiffTable(match, scopeColors) {
    const [original, colorFunction] = match;
    const entries = _.map(
      [...original.matchAll(DIFF_ENTRY_REGEXP)],
      ([, arrayKey, quotedKey, bareKey, value]) => {
        const scope = arrayKey || quotedKey || bareKey;
        const hex = scopeColors[scope];
        if (!hex) {
          return [scope, value];
        }
        return [scope, `${colorFunction}(${__.hexToRgb(hex).join(',')})`];
      },
    );

    return `new Map(Object.entries({${__.serializeEntries(entries)}}))`;
  },

  /**
   * Build the code block table, as hex strings converted by chalk at load time
   * @param {Array} match - CODE_TABLE_REGEXP match
   * @param {object} scopeColors - Map of scope → '#rrggbb'
   * @returns {string} Replacement table
   */
  buildCodeTable(match, scopeColors) {
    const [original] = match;
    const body = original.match(/Object\.entries\(\{(.*?)\}\)/)[1];
    const entries = _.chain([...body.matchAll(CODE_ENTRY_REGEXP)])
      .map(([, quotedKey, bareKey, value]) => {
        const scope = quotedKey || bareKey;
        const hex = scopeColors[scope];
        if (hex) {
          return [scope, `"${_.trimStart(hex, '#')}"`];
        }
        // A missing top-level scope renders as plain text, like reset does.
        // Dropping them frees room for the hex conversion helper.
        // Dotted scopes fall back to their parent, so they must be kept.
        const isTopLevelReset =
          value.endsWith('.reset') && !scope.includes('.');
        if (isTopLevelReset) {
          return null;
        }
        return [scope, value];
      })
      .compact()
      .value();
    const chalkVariable = _.chain(entries)
      .map(([, value]) => value.match(/^([\w$]+)\./)?.[1])
      .compact()
      .first()
      .value();

    return `new Map(Object.entries({${__.serializeEntries(entries)}}).map(([k,v])=>[k,typeof v=="string"?${chalkVariable}.hex("#"+v):v]))`;
  },

  /**
   * Replace the added/removed decoration colors, padding the rgb arguments
   * with spaces so each call keeps its length
   * @param {Array} match - DECORATION_TABLE_REGEXP match
   * @param {object} decorationColors - { added, removed } '#rrggbb' colors
   * @returns {string} Replacement code
   */
  buildDecorationTable(match, decorationColors) {
    const [original, colorFunction] = match;
    const call = _.escapeRegExp(`${colorFunction}(`);
    const targets = [
      {
        hex: decorationColors.removed,
        regexp: new RegExp(`(=${call})(\\d+,\\d+,\\d+ *)(\\);if)`),
      },
      {
        hex: decorationColors.added,
        regexp: new RegExp(`(addDecoration:${call})(\\d+,\\d+,\\d+ *)(\\)$)`),
      },
    ];

    return _.reduce(
      targets,
      (code, { hex, regexp }) => {
        if (!hex) {
          return code;
        }
        return code.replace(regexp, (_match, before, rgb, after) => {
          const newRgb = __.hexToRgb(hex).join(',').padEnd(rgb.length, ' ');
          return `${before}${newRgb}${after}`;
        });
      },
      original,
    );
  },

  /**
   * Serialize [key, value] pairs as a minified object literal body
   * @param {Array} entries - List of [key, value source code]
   * @returns {string} Object literal body
   */
  serializeEntries(entries) {
    return _.chain(entries)
      .map(([key, value]) => {
        const serializedKey = /^[\w$]+$/.test(key) ? key : `"${key}"`;
        return `${serializedKey}:${value}`;
      })
      .join(',')
      .value();
  },

  /**
   * Convert a hex color to rgb
   * @param {string} hex - '#rrggbb'
   * @returns {number[]} [red, green, blue]
   */
  hexToRgb(hex) {
    return _.chain(hex)
      .trimStart('#')
      .chunk(2)
      .map((pair) => parseInt(pair.join(''), 16))
      .value();
  },
};
