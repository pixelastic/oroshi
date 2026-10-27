import { firostError, read } from 'firost';
import { buildRaw } from './buildRaw.js';
import { draftRead } from './draftRead.js';
import { loadDraft } from './loadDraft.js';
import { renderBody } from './renderBody.js';
import { saveDraft } from './saveDraft.js';

export let __;

/**
 * Update the core of a Draft, and keep its attachments
 * @param {object} options - Update options
 * @param {string} options.draftId - Id of the Draft. Throws GMAIL_DRAFT_ID_MISSING if empty
 * @param {string} [options.to] - New recipient. Kept when absent
 * @param {string} [options.subject] - New subject. Kept when absent
 * @param {string} [options.body] - New body, sent as text/plain. Excludes bodyFile
 * @param {string} [options.bodyFile] - Path of a file holding the new body. A .md file is also sent as HTML. Excludes body. Throws GMAIL_BODY_CONFLICT if both are given
 * @returns {Promise<object>} { draftId, threadId, url, attachments }, the url opening the Draft in Gmail. Throws GMAIL_UPDATE_EMPTY if no option changes the Draft
 */
export async function draftUpdate(options) {
  const { draftId, bodyFile } = options;

  if (!draftId) {
    throw firostError('GMAIL_DRAFT_ID_MISSING', 'Pass the id of a Draft');
  }
  const hasChange = options.to || options.subject || options.body || bodyFile;
  if (!hasChange) {
    throw firostError(
      'GMAIL_UPDATE_EMPTY',
      'Pass at least one of --to, --subject, --body or --body-file',
    );
  }

  // Render the body first, so that a conflict fails before any API call
  const hasBody = options.body || bodyFile;
  const file = bodyFile && {
    path: bodyFile,
    content: await __.read(bodyFile),
  };
  const newBody = hasBody && renderBody({ body: options.body, file });

  const draft = await __.loadDraft(draftId);
  const { from, cc, inReplyTo, references, attachments } = draft;

  const mime = await __.buildRaw({
    from,
    to: options.to || draft.to,
    cc,
    subject: options.subject || draft.subject,
    body: newBody ? newBody.text : draft.text,
    // A new body replaces the old HTML, even when it has none of its own
    html: newBody ? newBody.html : draft.html,
    inReplyTo,
    references,
    attachments,
  });
  const saved = await __.saveDraft({
    draftId,
    threadId: draft.threadId,
    mime,
  });
  // Gmail gives new part ids to the saved attachments
  const { attachments: savedAttachments } = await __.draftRead({ draftId });

  return {
    draftId: saved.id,
    threadId: saved.message.threadId,
    url: `https://mail.google.com/mail/u/0/#drafts?compose=${saved.message.id}`,
    attachments: savedAttachments,
  };
}

__ = {
  buildRaw,
  draftRead,
  loadDraft,
  read,
  saveDraft,
};
