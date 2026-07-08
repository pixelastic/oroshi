import { consoleError } from 'firost';
/**
 * Makes an API call to Anthropic's Claude API with the provided prompt and diff
 * @param {object} options - Configuration object for the API call
 * @param {string} options.prompt - The system prompt to send to the API
 * @param {string} options.diff - The diff content to be processed by the model
 * @returns {Promise<object>} The parsed JSON response from the Anthropic API
 */
export async function callApi(options) {
  const { prompt, diff } = options;
  // Stop if diff is empty (e.g. binary-only staged files)
  if (!diff.trim()) {
    consoleError('Empty diff: nothing to send to the API.\n');
    process.exit(1);
  }
  // Stop if no Anthropic key
  const key = process.env.ANTHROPIC_API_KEY;
  if (!key) {
    consoleError('ANTHROPIC_API_KEY not set.\n');
    process.exit(1);
  }

  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': key,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      model: 'claude-sonnet-4-6',
      max_tokens: 1024,
      system: prompt,
      messages: [{ role: 'user', content: diff }],
    }),
  });

  if (!response.ok) {
    consoleError(`API error: ${response.status} ${response.statusText}\n`);
    process.exit(1);
  }

  const data = await response.json();
  return data.content[0].text;
}
