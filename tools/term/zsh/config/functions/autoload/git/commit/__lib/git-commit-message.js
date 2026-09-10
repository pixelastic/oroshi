import { fileURLToPath } from 'node:url';
import { _ } from 'golgoth';
import { run } from 'firost';
import { commitWithHint } from './commitWithHint.js';
import { commitWithoutHint } from './commitWithoutHint.js';
import { getRepo, init } from './config.js';
import { formatMessage } from './format.js';
import { getCommitHint } from './getCommitHint.js';

export let __;

export const IGNORED_FILES = ['yarn.lock'];

/**
 * Generate a commit message from staged files.
 * Short-circuits with a hardcoded message when only ignored files are staged.
 * @param {string} [repoPath] - Optional repo root path
 */
export async function main(repoPath) {
  __.init(repoPath);

  const repo = __.getRepo();
  const stagedFiles = await repo.stagedFilesWithStatus();

  // Nothing staged — the commit hook called us with no work to do
  if (_.isEmpty(stagedFiles)) {
    process.exit(1);
  }

  // Only yarn.lock staged — skip the API, use a hardcoded message
  const onlyYarnLock =
    stagedFiles.length === 1 && stagedFiles[0].name === 'yarn.lock';
  if (onlyYarnLock) {
    console.log('chore(deps): update yarn.lock');
    return;
  }

  // Different prompt/diff if we have a COMMIT_HINT.md (from ralph) or not
  const strategy = await __.getStrategy();

  const prompt = await strategy.getPrompt();
  const diff = await strategy.getDiff();

  if (!diff.trim()) {
    process.exit(1);
  }

  const result = await __.run(
    ['bin-zsh', 'claude-api', '--system', prompt, '--max-tokens', '1024'],
    { input: diff, stdout: false },
  );

  const commitMessage = __.formatMessage(result.stdout);
  console.log(commitMessage);
}

__ = {
  /**
   * @returns {Promise<object>} Commit strategy (with or without hint)
   */
  async getStrategy() {
    const commitHint = await getCommitHint();
    return commitHint ? commitWithHint : commitWithoutHint;
  },
  init,
  getRepo,
  run,
  formatMessage,
};

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  await main(process.argv[2]);
}
