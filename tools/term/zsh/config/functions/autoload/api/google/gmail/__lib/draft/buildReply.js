import { _ } from 'golgoth';
import addressparser from 'nodemailer/lib/addressparser/index.js';

export let __;

/**
 * Compute the addressing and the threading headers of a reply to a Message
 * @param {object} message - The Message to reply to
 * @param {string} message.from - From header
 * @param {string} message.replyTo - Reply-To header, or an empty string
 * @param {string} message.to - To header, or an empty string
 * @param {string} message.cc - Cc header, or an empty string
 * @param {string} message.subject - Subject header
 * @param {string} message.rfcMessageId - Message-ID header
 * @param {string} message.references - References header, or an empty string
 * @param {string[]} aliases - Addresses of the user, removed from the recipients
 * @returns {object} { from, to, cc, subject, inReplyTo, references }
 */
export function buildReply(message, aliases) {
  const { from, replyTo, subject, rfcMessageId, references } = message;
  const ownAddresses = _.map(aliases, _.toLower);
  const isOwn = ({ address }) => _.includes(ownAddresses, address);

  const [sender] = __.parse(from);
  const toOrigin = isOwn(sender) ? message.to : replyTo || from;
  const to = _.reject(__.parse(toOrigin), isOwn);
  const received = __.parse(message.to, message.cc);
  const cc = _.chain(received)
    .reject(isOwn)
    .differenceBy(to, 'address')
    .value();
  const receivingAddress = _.chain(received)
    .filter(isOwn)
    .get('0.address')
    .value();
  const alias = _.find(aliases, (item) => _.toLower(item) === receivingAddress);

  return {
    from: alias || aliases[0],
    to: __.format(to),
    cc: __.format(cc),
    subject: /^re:/i.test(subject) ? subject : `Re: ${subject}`,
    inReplyTo: rfcMessageId,
    references: _.chain([references, rfcMessageId]).compact().join(' ').value(),
  };
}

__ = {
  /**
   * Parse address headers into recipients
   * @param {...string} headers - Address headers, possibly empty
   * @returns {object[]} Recipients, as { address, text }: the lowercase address, and the original `Name <address>` form
   */
  parse(...headers) {
    return _.chain(headers)
      .flatMap((value) => addressparser(value))
      .map(({ name, address }) => ({
        address: _.toLower(address),
        text: name ? `${__.quote(name)} <${address}>` : address,
      }))
      .value();
  },
  /**
   * Quote a display name when it holds a special character
   * @param {string} name - Display name
   * @returns {string} The name, quoted if needed
   */
  quote(name) {
    return /[",;<>@()]/.test(name) ? `"${_.replace(name, /"/g, '\\"')}"` : name;
  },
  /**
   * Join recipients into an address header
   * @param {object[]} recipients - Recipients, as returned by parse
   * @returns {string} The header, or an empty string
   */
  format(recipients) {
    return _.chain(recipients).map('text').join(', ').value();
  },
};
