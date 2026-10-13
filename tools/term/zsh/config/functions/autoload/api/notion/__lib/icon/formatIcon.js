import { _ } from 'golgoth';

/**
 * Format the Icon of one Page, to give every command the same output
 * @param {object|null} [icon] - The icon of the Page, as returned by the API
 * @returns {string} The emoji, or the URL of the image, or an empty string when there is no Icon
 */
export function formatIcon(icon) {
  if (!icon) {
    return '';
  }

  // An emoji Icon has no url, an image Icon is under its own type key
  return icon.emoji ?? _.get(icon, [icon.type, 'url'], '');
}
