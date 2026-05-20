import { formatMessage, wrapLines } from '../format.js';

describe('formatMessage', () => {
  it.each([
    {
      title: 'subject longer than 72 chars stays on one line',
      input: dedent`
        feat(some-module): this is a very long subject line that exceeds the 72 character limit and must not be wrapped
      `,
      output: dedent`
        feat(some-module): this is a very long subject line that exceeds the 72 character limit and must not be wrapped
      `,
    },
    {
      title: 'subject split across multiple lines is joined into one',
      input: dedent`
        feat: a subject incorrectly
        wrapped by the agent

        body text here
      `,
      output: dedent`
        feat: a subject incorrectly wrapped by the agent

        body text here
      `,
    },
    {
      title: 'body lines exceeding 72 chars are wrapped at word boundaries',
      input: dedent`
        fix: short

        This is a long body line that definitely exceeds seventy-two characters and must be wrapped at a word boundary
      `,
      output: dedent`
        fix: short

        This is a long body line that definitely exceeds seventy-two characters
        and must be wrapped at a word boundary
      `,
    },
    {
      title: 'short body lines are reflowed into one line if they fit',
      input: dedent`
        fix: short subject

        Short body line one
        Short body line two
      `,
      output: dedent`
        fix: short subject

        Short body line one Short body line two
      `,
    },
  ])('$title', ({ input, output }) => {
    const actual = formatMessage(input);
    expect(actual).toEqual(output);
  });
});

describe('wrapLines', () => {
  it.each([
    {
      title: 'short lines are reflowed into one if they fit',
      input: ['Short line one', 'Short line two'],
      output: ['Short line one Short line two'],
    },
    {
      title: 'long line is wrapped at word boundary',
      input: [
        'This is a long body line that definitely exceeds seventy-two characters and must be wrapped',
      ],
      output: [
        'This is a long body line that definitely exceeds seventy-two characters',
        'and must be wrapped',
      ],
    },
    {
      title: 'two short lines are reflowed into one if they fit',
      input: ['Short line', 'that fits together'],
      output: ['Short line that fits together'],
    },
    {
      title: 'empty line paragraph break is preserved',
      input: ['First paragraph.', '', 'Second paragraph.'],
      output: ['First paragraph.', '', 'Second paragraph.'],
    },
    {
      title: 'custom maxLength is respected',
      input: ['one two three four five'],
      maxLength: 10,
      output: ['one two', 'three four', 'five'],
    },
  ])('$title', ({ input, output, maxLength }) => {
    const actual = wrapLines(input, maxLength);
    expect(actual).toEqual(output);
  });
});
