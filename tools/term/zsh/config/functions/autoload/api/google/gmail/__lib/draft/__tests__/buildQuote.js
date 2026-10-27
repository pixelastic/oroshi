import { buildQuote } from '../buildQuote.js';

describe('buildQuote', () => {
  const message = {
    // Local time, so that the test does not depend on the time zone
    date: new Date(2026, 9, 26, 10, 5).toString(),
    from: 'Bob <bob@example.com>',
    html: '<p>Hi</p>',
    text: 'Hi',
  };

  it('builds the attribution line with the date and the sender', () => {
    const actual = buildQuote(message);

    expect(actual.text).toMatch(
      /^On Mon, Oct 26, 2026 at 10:05, Bob <bob@example\.com> wrote:\n/,
    );
    expect(actual.html).toContain(
      'On Mon, Oct 26, 2026 at 10:05, Bob &lt;<a href="mailto:bob@example.com">bob@example.com</a>&gt; wrote:',
    );
  });

  it('wraps the original HTML in a blockquote of a gmail_quote container', () => {
    const actual = buildQuote(message);

    expect(actual.html).toMatch(/^<div class="gmail_quote[^"]*">/);
    expect(actual.html).toMatch(
      /<blockquote class="gmail_quote"[^>]*><p>Hi<\/p><\/blockquote><\/div>$/,
    );
  });

  it('falls back to the original text when there is no HTML', () => {
    const actual = buildQuote({
      ...message,
      html: '',
      text: 'a < b\nsecond line',
    });

    expect(actual.html).toContain('>a &lt; b<br>second line</blockquote>');
  });

  it('prefixes every line of the text quote with "> "', () => {
    const actual = buildQuote({ ...message, text: 'one\n\nthree' });

    expect(actual.text).toMatch(/ wrote:\n> one\n> \n> three$/);
  });

  it('quotes the HTML converted to text when there is no text', () => {
    const actual = buildQuote({
      ...message,
      text: '',
      html: '<p>Hi <b>you</b></p>',
    });

    expect(actual.text).toMatch(/ wrote:\n> Hi you$/);
  });

  it('keeps a bare address as the sender', () => {
    const actual = buildQuote({ ...message, from: 'bob@example.com' });

    expect(actual.text).toContain(', bob@example.com wrote:');
    expect(actual.html).toContain(
      ', <a href="mailto:bob@example.com">bob@example.com</a> wrote:',
    );
  });
});
