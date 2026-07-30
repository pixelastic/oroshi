import { __, md2gdocs } from '../md2gdocs.js';

describe('md2gdocs', () => {
  beforeEach(() => {
    vi.spyOn(__, 'readFile').mockReturnValue('# Test\nHello world');
    vi.spyOn(__, 'getAuth').mockReturnValue({ credentials: 'mock' });
    vi.spyOn(__, 'uploadDoc').mockReturnValue('mock-doc-id-123');
  });

  it('uses filename without extension as default title', async () => {
    await md2gdocs('/path/to/my-article.md');
    expect(__.uploadDoc).toHaveBeenCalledWith(
      expect.anything(),
      'my-article',
      expect.anything(),
    );
  });

  it('uses custom title when provided', async () => {
    await md2gdocs('/path/to/file.md', { title: 'Custom Name' });
    expect(__.uploadDoc).toHaveBeenCalledWith(
      expect.anything(),
      'Custom Name',
      expect.anything(),
    );
  });

  it('reads folder ID from environment variable', async () => {
    process.env.OROSHI_GOOGLE_DRIVE_DOCS_FOLDER_ID = 'test-folder-id';
    expect(__.FOLDER_ID).toEqual('test-folder-id');
  });

  it('returns Google Docs URL', async () => {
    const actual = await md2gdocs('/path/to/file.md');
    expect(actual).toEqual(
      'https://docs.google.com/document/d/mock-doc-id-123/edit',
    );
  });

  it('converts markdown to HTML before uploading', async () => {
    await md2gdocs('/path/to/file.md');
    expect(__.uploadDoc).toHaveBeenCalledWith(
      expect.anything(),
      expect.anything(),
      expect.stringContaining('<h1>Test</h1>'),
    );
  });
});

describe('markdownToHtml', () => {
  it.each([
    {
      title: 'h1 heading',
      input: '# Hello',
      expected: '<h1>Hello</h1>',
    },
    {
      title: 'h2 heading',
      input: '## Hello',
      expected: '<h2>Hello</h2>',
    },
    {
      title: 'h3 heading',
      input: '### Hello',
      expected: '<h3>Hello</h3>',
    },
    {
      title: 'paragraph',
      input: 'Hello world',
      expected: '<p>Hello world</p>',
    },
    {
      title: 'bold text',
      input: 'Some **bold** text',
      expected: '<p>Some <strong>bold</strong> text</p>',
    },
    {
      title: 'italic text',
      input: 'Some *italic* text',
      expected: '<p>Some <em>italic</em> text</p>',
    },
    {
      title: 'link',
      input: 'A [link](https://example.com) here',
      expected: '<p>A <a href="https://example.com">link</a> here</p>',
    },
    {
      title: 'bullet list',
      input: '- Item 1\n- Item 2',
      expected: '<ul><li>Item 1</li><li>Item 2</li></ul>',
    },
    {
      title: 'multiple paragraphs',
      input: 'First\n\nSecond',
      expected: '<p>First</p><p>Second</p>',
    },
    {
      title: 'image',
      input: '![alt text](https://example.com/img.png)',
      expected: '<p><img src="https://example.com/img.png" alt="alt text"></p>',
    },
    {
      title: 'table',
      input: '| A | B |\n|---|---|\n| 1 | 2 |',
      expected:
        '<table><thead><tr><th>A</th><th>B</th></tr></thead><tbody><tr><td>1</td><td>2</td></tr></tbody></table>',
    },
    {
      title: 'blockquote',
      input: '> This is a quote',
      expected: '<blockquote><p>This is a quote</p></blockquote>',
    },
    {
      title: 'multiline blockquote',
      input: '> First line\n> Second line',
      expected: '<blockquote><p>First line Second line</p></blockquote>',
    },
  ])('$title', ({ input, expected }) => {
    const actual = __.markdownToHtml(input);
    expect(actual).toEqual(expected);
  });

  it('converts mixed markdown document', () => {
    const input = '# Title\n\nSome **bold** text.\n\n- Item 1\n- Item 2';
    const actual = __.markdownToHtml(input);
    expect(actual).toEqual(
      '<h1>Title</h1><p>Some <strong>bold</strong> text.</p><ul><li>Item 1</li><li>Item 2</li></ul>',
    );
  });
});

describe('wrapInDocument', () => {
  it('wraps body in HTML document with CSS', () => {
    const actual = __.wrapInDocument('<p>Hello</p>');
    expect(actual).toContain('<html>');
    expect(actual).toContain('line-height: 1.6');
    expect(actual).toContain('<p>Hello</p>');
    expect(actual).toContain('</body></html>');
  });
});
