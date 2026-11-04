import { _ } from 'golgoth';
import { renderMermaidSVG } from 'beautiful-mermaid';

export let __;

const VAR_PATTERN = /var\((--[\w-]+)(?:\s*,\s*((?:[^()]|\([^()]*\))*))?\)/g;
const COLOR_MIX_PATTERN =
  /color-mix\(in srgb,\s*(#[0-9a-fA-F]{6})\s+(\d+)%,\s*(#[0-9a-fA-F]{6})\)/g;
const CUSTOM_PROPERTY_PATTERN = /(--[\w-]+)\s*:\s*([^;]+?)\s*;/g;

/**
 * Render Mermaid text to a self-contained SVG string, themed with the given
 * colors. The engine output relies on CSS variables that most SVG viewers do
 * not support, so they are resolved to hex values.
 * @param {string} input - Mermaid text
 * @param {object} theme - Hex colors: background, foreground, accent, line, muted
 * @returns {string} The SVG
 * @throws {Error} When the Mermaid syntax is invalid
 */
export function renderMermaid(input, theme) {
  const svg = renderMermaidSVG(input, {
    bg: theme.background,
    fg: theme.foreground,
    accent: theme.accent,
    line: theme.line,
    muted: theme.muted,
    font: 'sans-serif',
  });

  return __.flatten(svg, theme.background);
}

__ = {
  /**
   * Resolve CSS variables, force an opaque background and set a pixel size
   * @param {string} svg - SVG from the engine
   * @param {string} background - Hex color of the background
   * @returns {string} The flattened SVG
   */
  flatten(svg, background) {
    const variables = __.collectVariables(svg);

    const withoutRootRule = svg.replace(/<style>[\s\S]*?<\/style>/, (block) =>
      block.replace(/svg\s*\{[^}]*\}/, ''),
    );
    const resolved = __.resolveValue(withoutRootRule, variables).replace(
      /(<svg[^>]*?)\sstyle="[^"]*"/,
      '$1',
    );

    return __.fixBackground(resolved, background);
  },

  /**
   * List the CSS custom properties of the root style attribute and the style block
   * @param {string} svg - SVG from the engine
   * @returns {object} Value of each custom property, indexed by name
   */
  collectVariables(svg) {
    const rootStyle = svg.match(/<svg[^>]*style="([^"]*)"/)?.[1] ?? '';
    const styleBlock = svg.match(/<style>[\s\S]*?<\/style>/)?.[0] ?? '';

    return _.chain([rootStyle, styleBlock])
      .flatMap((text) => [...text.matchAll(CUSTOM_PROPERTY_PATTERN)])
      .map(([, name, value]) => [name, value])
      .fromPairs()
      .value();
  },

  /**
   * Replace every var() and color-mix() by its hex value, until none is left
   * @param {string} value - Text containing CSS functions
   * @param {object} variables - Value of each custom property
   * @returns {string} The text with hex colors only
   */
  resolveValue(value, variables) {
    const resolved = value
      .replace(
        VAR_PATTERN,
        (_match, name, fallback) => variables[name] ?? fallback ?? '',
      )
      .replace(COLOR_MIX_PATTERN, (_match, colorA, percent, colorB) =>
        __.mixColors(colorA, colorB, Number(percent) / 100),
      );

    return resolved === value ? value : __.resolveValue(resolved, variables);
  },

  /**
   * Mix two hex colors in sRGB
   * @param {string} colorA - Hex color
   * @param {string} colorB - Hex color
   * @param {number} ratio - Share of colorA, from 0 to 1
   * @returns {string} The mixed hex color
   */
  mixColors(colorA, colorB, ratio) {
    const channels = (hex) =>
      _.map([1, 3, 5], (index) => parseInt(hex.slice(index, index + 2), 16));
    const [rgbA, rgbB] = [channels(colorA), channels(colorB)];

    const mixed = _.chain(rgbA)
      .map((channel, index) => channel * ratio + rgbB[index] * (1 - ratio))
      .map((channel) => Math.round(channel).toString(16).padStart(2, '0'))
      .join('')
      .value();

    return `#${mixed}`;
  },

  /**
   * Set an explicit pixel size from the viewBox and cover it with an opaque rect
   * @param {string} svg - SVG with a viewBox
   * @param {string} background - Hex color of the background
   * @returns {string} The SVG
   */
  fixBackground(svg, background) {
    const openTag = svg.match(/<svg[^>]*>/)[0];
    const [x, y, width, height] = openTag
      .match(/viewBox="([^"]*)"/)[1]
      .split(/\s+/)
      .map(Number);

    const sizedTag = openTag
      .replace(/\swidth="[^"]*"/, '')
      .replace(/\sheight="[^"]*"/, '')
      .replace('<svg', `<svg width="${width}" height="${height}"`);
    const rect = `<rect x="${x}" y="${y}" width="${width}" height="${height}" fill="${background}"/>`;

    return svg.replace(openTag, `${sizedTag}${rect}`);
  },
};
