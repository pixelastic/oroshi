import { callApi } from './callApi.js';
import { commitWithHint } from './commitWithHint.js';
import { commitWithoutHint } from './commitWithoutHint.js';
import { formatMessage } from './format.js';
import { getCommitHint } from './getCommitHint.js';

// Different prompt/diff if we have a COMMIT_HINT.md (from ralph) or not
const commitHint = await getCommitHint();
const strategy = commitHint ? commitWithHint : commitWithoutHint;

// Call the API
const prompt = await strategy.getPrompt();
const diff = await strategy.getDiff();
const response = await callApi({ prompt, diff });

const commitMessage = formatMessage(response);
console.log(commitMessage);
