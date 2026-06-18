import { callApi } from './callApi.js';
import { commitWithHint } from './commitWithHint.js';
import { commitWithoutHint } from './commitWithoutHint.js';
import { formatMessage } from './format.js';
import { getCommitHint } from './getCommitHint.js';
import { getDeletedPlanName } from './getDeletedPlanName.js';

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
const response = await callApi({ prompt, diff });

const commitMessage = formatMessage(response);
console.log(commitMessage);
