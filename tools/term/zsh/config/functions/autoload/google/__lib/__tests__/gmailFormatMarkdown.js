import { gmailFormatMarkdown } from '../gmailFormatMarkdown.js';

describe('gmailFormatMarkdown', () => {
  const message = {
    id: 'a1',
    from: 'Alice Martin <alice@example.com>',
    to: 'bob@example.com',
    date: 'Fri, 03 Oct 2026 21:26:59 +0200',
    subject: 'Quarterly report',
    body: 'Please find the report attached.',
  };

  it('prints the labeled headers before the body', () => {
    const actual = gmailFormatMarkdown(message);

    expect(actual).toEqual(
      [
        '**From:** Alice Martin <alice@example.com>  ',
        '**To:** bob@example.com  ',
        '**Date:** Fri, 03 Oct 2026 21:26:59 +0200  ',
        '**Subject:** Quarterly report',
        '',
        'Please find the report attached.',
      ].join('\n'),
    );
  });

  it('skips headers that are empty', () => {
    const actual = gmailFormatMarkdown({ ...message, to: '' });

    expect(actual).toEqual(
      [
        '**From:** Alice Martin <alice@example.com>  ',
        '**Date:** Fri, 03 Oct 2026 21:26:59 +0200  ',
        '**Subject:** Quarterly report',
        '',
        'Please find the report attached.',
      ].join('\n'),
    );
  });
});
