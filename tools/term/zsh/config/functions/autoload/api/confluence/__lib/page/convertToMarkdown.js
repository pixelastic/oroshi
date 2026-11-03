import { _ } from 'golgoth';
import { run } from 'firost';

export let __;

/**
 * Convert the storage HTML of a Page to clean Markdown
 * @param {string} html - Storage HTML of the Page
 * @returns {Promise<string>} The Markdown, without the noisy comments
 */
export async function convertToMarkdown(html) {
  // go-tool-path is a zsh function, so it needs a zsh to run in
  const { stdout: converter } = await __.run(
    ['zsh', '-ic', 'go-tool-path "$@"', 'zsh', 'confluence-md'],
    { stdout: false, stderr: false },
  );
  const { stdout: markdown } = await __.run([_.trim(converter), 'html'], {
    input: html,
    stdout: false,
  });

  return __.removeNoisyComments(_.trim(markdown));
}

__ = {
  /**
   * Remove the comments the converter adds for macros and inline comments
   * @param {string} markdown - Markdown given by the converter
   * @returns {string} Markdown without the noisy comments
   */
  removeNoisyComments(markdown) {
    const noisyComments = [
      'Table of Contents',
      'Unsupported macro: panel',
      'Unsupported macro: toc',
    ];

    // The blank line after a comment goes with it
    const withoutMacros = _.reduce(
      noisyComments,
      (result, comment) => {
        return result
          .replaceAll(`<!-- ${comment} -->\n\n`, '')
          .replaceAll(`<!-- ${comment} -->`, '');
      },
      markdown,
    );

    // Inline comment markers carry a variable id
    return withoutMacros.replaceAll(/<!-- comment-ref: [0-9a-f-]+ -->/g, '');
  },
  run,
};
