import {
  __,
  formatMessage,
  getDiff,
  getStagedFiles,
} from '../git-commit-message.js';

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
      title: 'body lines already under 72 chars are not modified',
      input: dedent`
        fix: short subject

        Short body line one
        Short body line two
      `,
      output: dedent`
        fix: short subject

        Short body line one
        Short body line two
      `,
    },
  ])('$title', ({ input, output }) => {
    const actual = formatMessage(input);
    expect(actual).toEqual(output);
  });
});

describe('getStagedFiles', () => {
  it.each([
    {
      title: 'filters out yarn.lock from staged files',
      statusOutput: 'M  src/index.js\nM  yarn.lock\nA  lib/helper.js\n',
      expected: ['src/index.js', 'lib/helper.js'],
    },
    {
      title: 'returns empty array when nothing staged',
      statusOutput: '',
      expected: [],
    },
  ])('$title', async ({ statusOutput, expected }) => {
    __.gitStatus = vi.fn().mockReturnValue(statusOutput);
    const actual = await getStagedFiles();
    expect(actual).toEqual(expected);
  });
});

describe('getDiff', () => {
  it('returns diff output for given files', async () => {
    __.gitDiff = vi.fn().mockReturnValue('diff content');
    const actual = await getDiff(['src/index.js']);
    expect(actual).toEqual('diff content');
  });
});
