#!/usr/bin/env node
import { _ } from 'golgoth';
import { absolute, consoleError, dirname, read } from 'firost';
import Gilmore from 'gilmore';
import { formatMessage } from './format.js';

const EXCLUDED = ['yarn.lock'];

const key = process.env.ANTHROPIC_API_KEY;
if (!key) {
  process.stderr.write('ANTHROPIC_API_KEY not set.\n');
  process.exit(1);
}

const systemPrompt = await read(absolute(dirname(), 'prompt.md'));
const repo = Gilmore();

const allFiles = await repo.stagedFiles();
const files = _.reject(allFiles, (f) =>
  EXCLUDED.includes(_.last(f.split('/'))),
);

if (files.length === 0) {
  consoleError('Nothing staged.\n');
  process.exit(1);
}

const quotedFiles = files.map((f) => `"${f.replace(/"/g, '\\"')}"`);
const diff = await repo.run(`diff --cached -- ${quotedFiles.join(' ')}`);

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
    system: systemPrompt,
    messages: [{ role: 'user', content: diff }],
  }),
});

if (!response.ok) {
  consoleError(`API error: ${response.status} ${response.statusText}\n`);
  process.exit(1);
}

const data = await response.json();
const commitMessage = formatMessage(data.content[0].text);
console.log(commitMessage);
