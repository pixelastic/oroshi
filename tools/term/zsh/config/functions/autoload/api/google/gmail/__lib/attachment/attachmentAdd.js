import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { pMap } from 'golgoth';
import { firostError, isFile } from 'firost';
import { buildRaw } from '../draft/buildRaw.js';
import { draftRead } from '../draft/draftRead.js';
import { loadDraft } from '../draft/loadDraft.js';
import { saveDraft } from '../draft/saveDraft.js';
import { checkAttachmentsSize } from './checkAttachmentsSize.js';

export let __;

/**
 * Add files to a Draft, and keep its existing attachments
 * @param {object} options - Add options
 * @param {string} options.draftId - Id of the Draft. Throws GMAIL_DRAFT_ID_MISSING if empty
 * @param {string[]} options.files - Paths of the files to attach. Throws GMAIL_ATTACHMENT_FILES_MISSING if empty, and GMAIL_ATTACHMENT_FILE_NOT_FOUND if one does not exist
 * @returns {Promise<object>} { draftId, threadId, url, attachments }, the url opening the Draft in Gmail. Throws GMAIL_ATTACHMENTS_TOO_LARGE if the attachments are above 25 MB
 */
export async function attachmentAdd(options) {
  const { draftId, files } = options;

  if (!draftId) {
    throw firostError('GMAIL_DRAFT_ID_MISSING', 'Pass the id of a Draft');
  }
  if (!files?.length) {
    throw firostError(
      'GMAIL_ATTACHMENT_FILES_MISSING',
      'Pass the paths of the files to attach',
    );
  }

  // Read the files first, so that a missing file fails before any API call
  const newAttachments = await pMap(files, async (filepath) => {
    if (!(await __.isFile(filepath))) {
      throw firostError(
        'GMAIL_ATTACHMENT_FILE_NOT_FOUND',
        `File not found: ${filepath}`,
      );
    }
    return {
      filename: path.basename(filepath),
      content: await __.readFile(filepath),
    };
  });

  const draft = await __.loadDraft(draftId);
  const attachments = [...draft.attachments, ...newAttachments];
  __.checkAttachmentsSize(attachments);

  const mime = await __.buildRaw({
    from: draft.from,
    to: draft.to,
    cc: draft.cc,
    subject: draft.subject,
    body: draft.text,
    html: draft.html,
    inReplyTo: draft.inReplyTo,
    references: draft.references,
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
  checkAttachmentsSize,
  draftRead,
  isFile,
  loadDraft,
  readFile,
  saveDraft,
};
