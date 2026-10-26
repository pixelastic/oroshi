import { _, dayjs } from 'golgoth';
import { header } from '../header.js';
import { senderName } from '../senderName.js';

export let __;

/**
 * Format one Message (a Gmail conversation), to give every command the same
 * output
 * @param {object} response - The conversation, as returned by the Gmail API with the metadata format
 * @returns {object} The Message as { id, date, count, authors, subject, snippet, unread }
 */
export function formatMessage(response) {
  const mails = _.chain(response.messages)
    .sortBy((mail) => Number(mail.internalDate))
    .map(__.formatMail)
    .value();
  // Like the Gmail inbox, show the last mail received in the inbox, not the
  // replies sent from it
  const shown = _.findLast(mails, 'inbox') || _.last(mails);
  const [unreadMails, readMails] = _.partition(mails, 'unread');
  const authors = _.chain([...unreadMails, ...readMails])
    .map((mail) => senderName(mail.from))
    .uniq()
    .value();

  return {
    id: response.id,
    date: __.isoDate(_.last(mails).date),
    count: mails.length,
    authors,
    subject: shown.subject,
    snippet: shown.snippet,
    unread: !_.isEmpty(unreadMails),
  };
}

__ = {
  /**
   * Flatten one Gmail mail
   * @param {object} mail - Gmail message resource, fetched with the metadata format
   * @returns {object} The mail as { from, subject, date, snippet, unread, inbox }
   */
  formatMail(mail) {
    return {
      from: header(mail, 'From'),
      subject: header(mail, 'Subject'),
      date: header(mail, 'Date'),
      snippet: mail.snippet || '',
      unread: _.includes(mail.labelIds, 'UNREAD'),
      inbox: _.includes(mail.labelIds, 'INBOX'),
    };
  },

  /**
   * Format a Date header as an ISO 8601 date
   * @param {string} date - Date header
   * @returns {string} ISO 8601 date, or an empty string if invalid
   */
  isoDate(date) {
    const parsed = dayjs(date);
    return parsed.isValid() ? parsed.toISOString() : '';
  },
};
