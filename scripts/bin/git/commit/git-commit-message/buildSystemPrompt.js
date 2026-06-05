import { absolute, dirname, read } from 'firost';
import { getCommitHint } from './getCommitHint.js';

export let __;

const HINT_INSTRUCTION =
  'The following hint was written by the agent who implemented these changes. ' +
  'Treat it as the primary source for type, scope, and subject. ' +
  'Use the diff to verify and refine the body.';

/**
 * Builds the final system prompt by reading the template and injecting
 * the commit hint if one is available in the current worktree.
 * @returns {Promise<string>} Final system prompt
 */
export async function buildSystemPrompt() {
  const template = await __.readTemplate();
  const hint = await __.getHint();

  if (!hint) {
    return template.replace('{{COMMIT_HINT}}', '');
  }
  return template.replace('{{COMMIT_HINT}}', `${HINT_INSTRUCTION}\n${hint}`);
}

__ = {
  /**
   * @returns {Promise<string>} Raw contents of prompt.md
   */
  readTemplate() {
    return read(absolute(dirname(), 'prompt.md'));
  },
  /**
   * @returns {Promise<string|null>} Commit hint or null
   */
  getHint() {
    return getCommitHint();
  },
};
