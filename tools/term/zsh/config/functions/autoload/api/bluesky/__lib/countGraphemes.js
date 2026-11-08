/**
 * Count the graphemes of a text, as a reader sees them
 * @param {string} text - Text to measure
 * @returns {number} Number of graphemes
 */
export function countGraphemes(text) {
  return [...new Intl.Segmenter().segment(text)].length;
}
