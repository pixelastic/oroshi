import { renderBody } from '../renderBody.js';

describe('renderBody', () => {
  const markdown = '- one\n- **two**\n\nSee [docs](https://example.com)';

  it('returns the --body text as is, without HTML', () => {
    const actual = renderBody({ body: '- one\n**two**' });

    expect(actual).toEqual({ text: '- one\n**two**' });
  });

  it('returns the content of a .txt file as is, without HTML', () => {
    const actual = renderBody({
      file: { path: '/tmp/body.txt', content: markdown },
    });

    expect(actual).toEqual({ text: markdown });
  });

  it('converts bullets, bold text and links of a .md file to HTML', () => {
    const actual = renderBody({
      file: { path: '/tmp/body.md', content: markdown },
    });

    expect(actual.html).toContain('<ul>');
    expect(actual.html).toContain('<li>one</li>');
    expect(actual.html).toContain('<strong>two</strong>');
    expect(actual.html).toContain('<a href="https://example.com">docs</a>');
  });

  it('keeps the Markdown source as the text of a .md file', () => {
    const actual = renderBody({
      file: { path: '/tmp/BODY.MD', content: markdown },
    });

    expect(actual).toHaveProperty('text', markdown);
  });

  it.each([
    {
      title: 'both --body and --body-file are given',
      options: { body: 'hi', file: { path: '/tmp/body.md', content: 'hi' } },
      expected: 'GMAIL_BODY_CONFLICT',
    },
    {
      title: 'neither --body nor --body-file is given',
      options: {},
      expected: 'GMAIL_BODY_MISSING',
    },
  ])('fails when $title', ({ options, expected }) => {
    let actual = null;
    try {
      renderBody(options);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', expected);
  });
});
