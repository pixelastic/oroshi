import readline from 'node:readline';
import { consoleInfo } from 'firost';
import { openSession } from '../openSession.js';

const VINTED_URL = 'https://www.vinted.fr';

const context = await openSession();
const page = context.pages()[0] ?? (await context.newPage());
// An expired session redirects to /session-refresh, which never finishes
// loading and blocks the login. Dropping the stale cookies avoids the redirect.
await context.clearCookies({ domain: /vinted\./ });
await page.goto(VINTED_URL, { waitUntil: 'commit' });

consoleInfo('Log in to Vinted by hand, then close the browser or press Enter');

// Resolves when the user closes the browser
const browserClosed = new Promise((resolve) => context.on('close', resolve));

// Resolves when the user presses Enter
const input = readline.createInterface({ input: process.stdin });
const enterPressed = new Promise((resolve) => input.once('line', resolve));

await Promise.race([browserClosed, enterPressed]);
input.close();
await context.close();
