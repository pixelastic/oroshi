import { _ } from 'golgoth';
import { firostError } from 'firost';
import { buildRaw } from '../draft/buildRaw.js';
import { draftRead } from '../draft/draftRead.js';
import { getDraft } from '../draft/getDraft.js';
import { loadDraft } from '../draft/loadDraft.js';
import { saveDraft } from '../draft/saveDraft.js';
import { extractAttachments } from '../extractAttachments.js';

export let __;

/**
 * Remove one attachment of a Draft, and keep the others
 * @param {object} options - Remove options
 * @param {string} options.draftId - Id of the Draft. Throws GMAIL_DRAFT_ID_MISSING if empty
 * @param {string} options.partId - Part id, as listed in the attachments of gmail-draft-read. Throws GMAIL_PART_ID_MISSING if empty, and GMAIL_ATTACHMENT_NOT_FOUND if no attachment has it
 * @returns {Promise<object>} { draftId, threadId, url, attachments }, the url opening the Draft in Gmail
 */
export async function attachmentRemove(options) {
  const { draftId, partId } = options;

  if (!draftId) {
    throw firostError('GMAIL_DRAFT_ID_MISSING', 'Pass the id of a Draft');
  }
  if (!partId) {
    throw firostError('GMAIL_PART_ID_MISSING', 'Pass the --partId of the part');
  }

  const draft = await __.loadDraft(draftId);

  // The Nth attachment of the payload is the Nth attachment of the parsed MIME
  const fullDraft = await __.getDraft(draftId, 'full');
  const index = _.findIndex(
    extractAttachments(fullDraft.message.payload),
    (item) => item.partId === partId,
  );
  if (index === -1) {
    throw firostError(
      'GMAIL_ATTACHMENT_NOT_FOUND',
      `Attachment not found in Draft ${draftId}: part ${partId}`,
    );
  }

  const mime = await __.buildRaw({
    from: draft.from,
    to: draft.to,
    cc: draft.cc,
    subject: draft.subject,
    body: draft.text,
    html: draft.html,
    inReplyTo: draft.inReplyTo,
    references: draft.references,
    attachments: _.filter(draft.attachments, (_item, i) => i !== index),
  });
  const saved = await __.saveDraft({
    draftId,
    threadId: draft.threadId,
    mime,
  });
  // Gmail gives new part ids to the saved attachments
  const { attachments } = await __.draftRead({ draftId });

  return {
    draftId: saved.id,
    threadId: saved.message.threadId,
    url: `https://mail.google.com/mail/u/0/#drafts?compose=${saved.message.id}`,
    attachments,
  };
}

__ = {
  buildRaw,
  draftRead,
  getDraft,
  loadDraft,
  saveDraft,
};
