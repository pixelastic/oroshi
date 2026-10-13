/**
 * Build the title of a Database, as the API expects it
 * @param {string} text - Title as plain text
 * @returns {Array<object>} The title as rich text
 */
export function buildTitle(text) {
  return [{ type: 'text', text: { content: text } }];
}
