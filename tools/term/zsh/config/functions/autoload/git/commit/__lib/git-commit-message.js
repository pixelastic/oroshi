import { consoleError, run } from 'firost';
import { commitWithHint } from './commitWithHint.js';
import { commitWithoutHint } from './commitWithoutHint.js';
import { init } from './config.js';
import { formatMessage } from './format.js';
import { getCommitHint } from './getCommitHint.js';
import { getDeletedPlanName } from './getDeletedPlanName.js';

init(process.argv[2]);

// Short-circuit for plan deletion commits — no API call needed
const deletedPlanName = await getDeletedPlanName();
if (deletedPlanName) {
  console.log(`plan(${deletedPlanName}): delete completed plan`);
  process.exit(0);
}

// Different prompt/diff if we have a COMMIT_HINT.md (from ralph) or not
const commitHint = await getCommitHint();
const strategy = commitHint ? commitWithHint : commitWithoutHint;

// Call the API
const prompt = await strategy.getPrompt();
const diff = await strategy.getDiff();

if (!diff.trim()) {
  consoleError('Empty diff: nothing to send to the API.\n');
  process.exit(1);
}

const result = await run(
  ['bin-zsh', 'claude-api', '--system', prompt, '--max-tokens', '1024'],
  { input: diff, stdout: false },
);

const commitMessage = formatMessage(result.stdout);
console.log(commitMessage);
