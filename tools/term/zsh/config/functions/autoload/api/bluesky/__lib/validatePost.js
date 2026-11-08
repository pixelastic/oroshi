import { _ } from 'golgoth';
import { countGraphemes } from './countGraphemes.js';

export let __;

const MAX_GRAPHEMES = 300;
const MAX_BYTES = 3000;

/**
 * Find what is wrong with parsed posts, without any network call
 * Length counts the final text of a post, not its Markdown source.
 * @param {object[]} posts - Posts returned by parsePostMarkdown
 * @returns {object[]} Violations, each with a `code`, a `level`, a `message`
 * and the `line` of the source where the post starts
 */
export function validatePost(posts) {
  return _.flatMap(posts, (post) => {
    return _.map(__.findProblems(post.text), (problem) => ({
      ...problem,
      line: post.line,
    }));
  });
}

__ = {
  /**
   * Check the text of one post against the limits of Bluesky
   * @param {string} text - Final text of the post
   * @returns {object[]} Problems, each with a `code`, a `level` and a `message`
   */
  findProblems(text) {
    if (_.trim(text) === '') {
      return [
        { code: 'empty', level: 'error', message: 'The post has no text' },
      ];
    }

    const graphemes = countGraphemes(text);
    const bytes = Buffer.byteLength(text);
    const problems = [];
    if (graphemes > MAX_GRAPHEMES) {
      problems.push({
        code: 'too-long-graphemes',
        level: 'error',
        message: `The post has ${graphemes} graphemes, the limit is ${MAX_GRAPHEMES}`,
      });
    }
    if (bytes > MAX_BYTES) {
      problems.push({
        code: 'too-long-bytes',
        level: 'error',
        message: `The post has ${bytes} bytes, the limit is ${MAX_BYTES}`,
      });
    }
    return problems;
  },
};
