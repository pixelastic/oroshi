import { mkdtemp, readFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { __, gmailAttachment } from '../attachment.js';
import { gmailMessages } from '../messages.js';

describe('gmailAttachment', () => {
  let tmp;
  beforeEach(async () => {
    tmp = await mkdtemp(path.join(os.tmpdir(), 'gmail-attachment-'));
    vi.spyOn(__, 'googleAuth').mockReturnValue({ fake: 'auth' });
    vi.spyOn(gmailMessages, 'getAttachment').mockReturnValue({
      filename: 'report.pdf',
      data: Buffer.from('content'),
    });
  });

  it.each([
    {
      title: 'existing directory keeps the remote filename',
      out: (dir) => dir,
      expected: (dir) => path.join(dir, 'report.pdf'),
    },
    {
      title: 'unknown path is used as the file path',
      out: (dir) => path.join(dir, 'sub', 'renamed.pdf'),
      expected: (dir) => path.join(dir, 'sub', 'renamed.pdf'),
    },
  ])('$title', async ({ out, expected }) => {
    const actual = await gmailAttachment('pro', {
      messageId: 'a1',
      partId: '1.2',
      out: out(tmp),
    });

    expect(actual).toEqual(expected(tmp));
    expect(await readFile(actual, 'utf8')).toEqual('content');
  });

  it('saves in the current directory without --out', async () => {
    const cwd = process.cwd();
    process.chdir(tmp);
    let actual;
    try {
      actual = await gmailAttachment('pro', {
        messageId: 'a1',
        partId: '1.2',
      });
    } finally {
      process.chdir(cwd);
    }

    expect(await readFile(actual, 'utf8')).toEqual('content');
    expect(path.basename(actual)).toEqual('report.pdf');
    expect(await readFile(path.join(tmp, 'report.pdf'), 'utf8')).toEqual(
      'content',
    );
  });

  it('uses only the basename of the remote filename', async () => {
    vi.spyOn(gmailMessages, 'getAttachment').mockReturnValue({
      filename: '../../evil.sh',
      data: Buffer.from('x'),
    });

    const actual = await gmailAttachment('pro', {
      messageId: 'a1',
      partId: '1.2',
      out: tmp,
    });

    expect(actual).toEqual(path.join(tmp, 'evil.sh'));
  });
});
