import { _ } from 'golgoth';

/**
 * Keep the display name of a sender, or the raw value if there is none
 * @param {string} from - From header, like `Name <name@example.com>`
 * @returns {string} Display name
 */
export function gmailSenderName(from) {
  const name = _.chain(from)
    .replace(/<[^>]*>/, '')
    .trim()
    .trim('"')
    .value();
  return name || from;
}
