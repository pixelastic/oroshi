import { __, convertToMarkdown } from '../convertToMarkdown.js';

describe('convertToMarkdown', () => {
  /**
   * Mock the child process: the first call resolves the converter path, the
   * second converts the HTML
   * @param {string} markdown - What the converter prints on stdout
   */
  function mockConverter(markdown) {
    vi.spyOn(__, 'run').mockImplementation((command) => {
      if (command[0] === 'zsh') {
        return { stdout: '/bin/confluence-md' };
      }
      return { stdout: markdown };
    });
  }

  it('passes the HTML on stdin and returns the Markdown', async () => {
    mockConverter('## Intro');

    const actual = await convertToMarkdown('<h2>Intro</h2>');

    expect(__.run).toHaveBeenCalledWith(
      ['zsh', '-ic', 'go-tool-path "$@"', 'zsh', 'confluence-md'],
      { stdout: false, stderr: false },
    );
    expect(__.run).toHaveBeenCalledWith(['/bin/confluence-md', 'html'], {
      input: '<h2>Intro</h2>',
      stdout: false,
    });
    expect(actual).toEqual('## Intro');
  });

  it.each([
    {
      title: 'removes the table of contents comment and its blank line',
      input: '<!-- Table of Contents -->\n\n## Intro',
      expected: '## Intro',
    },
    {
      title: 'removes the table of contents comment on the same line',
      input: '<!-- Table of Contents -->Before',
      expected: 'Before',
    },
    {
      title: 'removes the unsupported panel macro comment',
      input: 'Before\n\n<!-- Unsupported macro: panel -->\n\nAfter',
      expected: 'Before\n\nAfter',
    },
    {
      title: 'removes the unsupported toc macro comment',
      input: '## Intro\n\n<!-- Unsupported macro: toc -->\n\nAfter',
      expected: '## Intro\n\nAfter',
    },
    {
      title: 'removes an inline comment marker with a uuid',
      input:
        'Run <!-- comment-ref: 3eb60cf2-972f-44fa-92fb-4f800970875b -->the agent now',
      expected: 'Run the agent now',
    },
    {
      title: 'removes an inline comment marker with another uuid',
      input:
        'Run <!-- comment-ref: 00000000-aaaa-bbbb-cccc-111111111111 -->the agent now',
      expected: 'Run the agent now',
    },
    {
      title: 'keeps the other HTML comments',
      input: '<!-- Unsupported macro: jira -->\n\nText',
      expected: '<!-- Unsupported macro: jira -->\n\nText',
    },
  ])('$title', async ({ input, expected }) => {
    mockConverter(input);

    const actual = await convertToMarkdown('<p>Any</p>');

    expect(actual).toEqual(expected);
  });
});
