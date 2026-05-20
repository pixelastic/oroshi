#!/usr/bin/env node
import { realpathSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { _ } from 'golgoth';
import { run as shell } from 'firost';

export let __;

const SYSTEM_PROMPT = `# Commit Writer

## Overview

Generate one commit message in Conventional Commits format. Output only the message — no explanations, no analysis, no code blocks.

## Core Workflow

### Step 1 — Identify the change

Goal: isolate the single most significant change in the diff.

Read the diff. If it touches multiple unrelated areas, pick ONE most significant change. Ignore the rest.

### Step 2 — Write the subject line

Goal: produce a subject line that stands alone.

Format: \`type(scope): description\`

Types: \`feat\`, \`fix\`, \`refactor\`, \`perf\`, \`test\`, \`docs\`, \`style\`, \`chore\`

- Imperative mood, ≤72 characters
- Must stand alone — someone reading \`git log\` should understand the change without the diff

### Step 3 — Write the body

Goal: state the concrete impact in plain prose.

Skip the body only when the change is purely mechanical with no context to add: typo fix, dependency version bump, branch merge, whitespace-only. If in doubt, write it.

2 sentences max. What problem is solved, what is now possible, what is prevented.

Never enumerate. Describe the outcome, not the mechanism.

### Step 4 — Output

Goal: emit the message and nothing else.

Plain text only. No attribution, no code blocks, no preamble, no explanation.`;

/**
 * Formats a raw commit message from the API into a properly wrapped string.
 * Subject line is kept intact; body lines are wrapped at 72 characters.
 * @param {string} raw - Raw commit message string
 * @returns {string} Formatted commit message
 */
export function formatMessage(raw) {
  const lines = raw.split('\n');
  const blankIndex = lines.indexOf('');

  if (blankIndex === -1) {
    return lines.join(' ');
  }

  const subject = lines.slice(0, blankIndex).join(' ');
  const body = lines.slice(blankIndex + 1);

  const wrappedBody = _.chain(body)
    .map((line) => (line.length <= 72 ? [line] : __.wrapLine(line)))
    .flatten()
    .value();

  return [subject, '', ...wrappedBody].join('\n');
}

/**
 * Returns staged file paths, excluding yarn.lock.
 * @returns {Promise<string[]>} Staged file paths
 */
export async function getStagedFiles() {
  const output = await __.gitStatus();
  return _.chain(output.split('\n'))
    .map((line) => line.trimEnd())
    .filter((line) => line.length > 0)
    .filter((line) => line[0] !== ' ' && !line.startsWith('??'))
    .map((line) => line.slice(3))
    .filter((file) => file !== 'yarn.lock')
    .value();
}

/**
 * Returns the staged diff for the given files.
 * @param {string[]} files - Staged file paths
 * @returns {Promise<string>} Diff output
 */
export async function getDiff(files) {
  return __.gitDiff(files);
}

/**
 * Calls the Anthropic API to generate a commit message from the diff.
 * @param {string} diff - Staged diff
 * @returns {Promise<string>} Raw commit message
 */
export async function generateMessage(diff) {
  return __.apiCall(diff);
}

/**
 * Orchestrates the full commit message generation flow.
 * Writes the formatted message to stdout; exits 1 on any error.
 * @returns {Promise<void>}
 */
export async function run() {
  const files = await getStagedFiles();
  if (files.length === 0) {
    process.stderr.write('Nothing staged.\n');
    process.exit(1);
  }
  const diff = await getDiff(files);
  const raw = await generateMessage(diff);
  process.stdout.write(formatMessage(raw));
}

__ = {
  /**
   * Wraps a single line at 72 characters on word boundaries.
   * @param {string} line - Line to wrap
   * @returns {string[]} Array of wrapped lines
   */
  wrapLine(line) {
    return _.reduce(
      line.split(' '),
      (acc, word) => {
        const last = _.last(acc);
        if (!last || `${last} ${word}`.length > 72) return [...acc, word];
        return [..._.initial(acc), `${last} ${word}`];
      },
      [],
    );
  },

  /**
   * Runs rtk git status --porcelain and returns raw output.
   * @returns {Promise<string>} Raw git status output
   */
  async gitStatus() {
    const { stdout } = await shell('rtk git status --porcelain');
    return stdout;
  },

  /**
   * Runs rtk git diff --cached for the given files.
   * @param {string[]} files - File paths to diff
   * @returns {Promise<string>} Diff output
   */
  async gitDiff(files) {
    const { stdout } = await shell(
      `rtk git diff --cached -- ${files.join(' ')}`,
    );
    return stdout;
  },

  /**
   * Calls the Anthropic API and returns the raw commit message.
   * @param {string} diff - Staged diff to send as user message
   * @returns {Promise<string>} Raw commit message text
   */
  async apiCall(diff) {
    const key = process.env.ANTHROPIC_API_KEY;
    if (!key) throw new Error('ANTHROPIC_API_KEY not set');

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
        system: SYSTEM_PROMPT,
        messages: [{ role: 'user', content: diff }],
      }),
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.status} ${response.statusText}`);
    }

    const data = await response.json();
    return data.content[0].text;
  },
};

const isMain = realpathSync(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  run().catch((err) => {
    process.stderr.write(`${err.message}\n`);
    process.exit(1);
  });
}
