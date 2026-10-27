import { _ } from 'golgoth';
import { convert } from 'html-to-text';
import addressparser from 'nodemailer/lib/addressparser/index.js';

export let __;

const BLOCKQUOTE_STYLE =
  'margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex';

/**
 * Build the quote of a Message, like the Gmail web interface does in a reply
 * @param {object} message - The Message to quote
 * @param {string} message.date - Date header
 * @param {string} message.from - From header
 * @param {string} message.html - HTML body, or an empty string
 * @param {string} message.text - Text body, or an empty string
 * @returns {object} { html, text }, the quote for each part of the reply
 */
export function buildQuote(message) {
  const { date, from, html, text } = message;
  const [sender] = addressparser(from);
  const when = __.formatDate(date);

  const original =
    html || _.chain(text).escape().replace(/\r?\n/g, '<br>').value();
  const quotedHtml = [
    '<div class="gmail_quote gmail_quote_container">',
    `<div dir="ltr" class="gmail_attr">${__.attribution(when, __.htmlSender(sender))}<br></div>`,
    `<blockquote class="gmail_quote" style="${BLOCKQUOTE_STYLE}">${original}</blockquote>`,
    '</div>',
  ].join('');

  const plain =
    text ||
    convert(html, {
      wordwrap: false,
      selectors: [{ selector: 'img', format: 'skip' }],
    });
  const quotedText = _.chain(plain)
    .trimEnd()
    .split(/\r?\n/)
    .map((line) => `> ${line}`)
    .unshift(__.attribution(when, __.textSender(sender)))
    .join('\n')
    .value();

  return { html: quotedHtml, text: quotedText };
}

__ = {
  /**
   * Write the attribution line of a quote
   * @param {string} when - Formatted date
   * @param {string} sender - Formatted sender
   * @returns {string} The line
   */
  attribution(when, sender) {
    return `On ${when}, ${sender} wrote:`;
  },
  /**
   * Format a date like the English Gmail web interface
   * @param {string} date - Date header
   * @returns {string} Like `Mon, Oct 26, 2026 at 10:05`, in local time
   */
  formatDate(date) {
    const day = new Intl.DateTimeFormat('en-US', {
      weekday: 'short',
      day: 'numeric',
      month: 'short',
      year: 'numeric',
    });
    const time = new Intl.DateTimeFormat('en-US', {
      hour: '2-digit',
      minute: '2-digit',
      hourCycle: 'h23',
    });
    const parsed = new Date(date);
    return `${day.format(parsed)} at ${time.format(parsed)}`;
  },
  /**
   * Format a sender as plain text
   * @param {object} sender - As parsed by addressparser
   * @returns {string} `Name <address>`, or the bare address
   */
  textSender(sender) {
    const { name, address } = sender;
    return name ? `${name} <${address}>` : address;
  },
  /**
   * Format a sender as HTML, with a mailto link
   * @param {object} sender - As parsed by addressparser
   * @returns {string} `Name <address>` with the address linked, or the linked bare address
   */
  htmlSender(sender) {
    const { name, address } = sender;
    const link = `<a href="mailto:${_.escape(address)}">${_.escape(address)}</a>`;
    return name ? `${_.escape(name)} &lt;${link}&gt;` : link;
  },
};
