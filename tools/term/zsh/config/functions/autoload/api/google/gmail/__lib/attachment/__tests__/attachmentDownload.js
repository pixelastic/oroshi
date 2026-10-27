import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { mkdirp, remove, tmpDirectory } from 'firost';
import { __, attachmentDownload } from '../attachmentDownload.js';

describe('attachmentDownload', () => {
  let tmp;
  beforeEach(async () => {
    tmp = tmpDirectory('attachmentDownload');
    await mkdirp(tmp);
    vi.spyOn(__, 'getMessage').mockReturnValue({
      id: 'm1',
      payload: { partId: '' },
    });
    vi.spyOn(__, 'callApi').mockReturnValue({
      size: 7,
      data: Buffer.from('content').toString('base64url'),
    });
    vi.spyOn(__, 'extractAttachments').mockReturnValue([
      { partId: '1', attachmentId: 'att-1', filename: 'other.txt' },
      { partId: '1.2', attachmentId: 'att-2', filename: 'report.pdf' },
    ]);
  });

  afterEach(async () => {
    await remove(tmp);
  });

  it('reads the Message in full format, then fetches the attachment of the part', async () => {
    await attachmentDownload({ messageId: 'm1', partId: '1.2', out: tmp });

    expect(__.getMessage).toHaveBeenCalledWith('m1', {
      query: { format: 'full' },
    });
    expect(__.callApi).toHaveBeenCalledWith('messages/m1/attachments/att-2');
  });

  it('saves in the current directory with the remote filename without --out', async () => {
    vi.spyOn(process, 'cwd').mockReturnValue(tmp);

    const actual = await attachmentDownload({ messageId: 'm1', partId: '1.2' });

    expect(path.basename(actual)).toEqual('report.pdf');
    expect(await readFile(path.join(tmp, 'report.pdf'), 'utf8')).toEqual(
      'content',
    );
  });

  it('saves inside an existing directory with the remote filename', async () => {
    const actual = await attachmentDownload({
      messageId: 'm1',
      partId: '1.2',
      out: tmp,
    });

    expect(actual).toEqual(path.join(tmp, 'report.pdf'));
    expect(await readFile(actual, 'utf8')).toEqual('content');
  });

  it('saves at the given file path', async () => {
    const out = path.join(tmp, 'sub', 'renamed.pdf');

    const actual = await attachmentDownload({
      messageId: 'm1',
      partId: '1.2',
      out,
    });

    expect(actual).toEqual(out);
    expect(await readFile(out, 'utf8')).toEqual('content');
  });

  it('saves the decoded bytes of the base64url data', async () => {
    const bytes = Buffer.from([0xfb, 0xff, 0xfe, 0x00, 0x80]);
    vi.spyOn(__, 'callApi').mockReturnValue({
      size: 5,
      data: bytes.toString('base64url'),
    });

    const actual = await attachmentDownload({
      messageId: 'm1',
      partId: '1.2',
      out: tmp,
    });

    expect(await readFile(actual)).toEqual(bytes);
  });

  it('uses only the basename of the remote filename', async () => {
    vi.spyOn(__, 'extractAttachments').mockReturnValue([
      { partId: '1.2', attachmentId: 'att-2', filename: '../../evil.sh' },
    ]);

    const actual = await attachmentDownload({
      messageId: 'm1',
      partId: '1.2',
      out: tmp,
    });

    expect(actual).toEqual(path.join(tmp, 'evil.sh'));
  });

  it.each([
    {
      title: 'a missing message id',
      options: { partId: '1.2' },
      code: 'GMAIL_MESSAGE_ID_MISSING',
    },
    {
      title: 'a missing part id',
      options: { messageId: 'm1' },
      code: 'GMAIL_PART_ID_MISSING',
    },
    {
      title: 'an unknown part',
      options: { messageId: 'm1', partId: '9.9' },
      code: 'GMAIL_ATTACHMENT_NOT_FOUND',
    },
  ])('fails with $code on $title', async ({ options, code }) => {
    let actual = null;
    try {
      await attachmentDownload({ ...options, out: tmp });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', code);
  });

  it('calls no API when the part id is missing', async () => {
    try {
      await attachmentDownload({ messageId: 'm1' });
    } catch {
      // The error is checked in the test above
    }

    expect(__.getMessage).not.toHaveBeenCalled();
  });
});
