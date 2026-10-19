import os from 'node:os';
import path from 'node:path';
import { chromium } from 'playwright';

const PROFILE_DIRECTORY = path.join(
  os.homedir(),
  '.local/share/vinted-poster/profile',
);

/**
 * Open Chrome on the dedicated Vinted profile
 * The browser is visible, and the profile keeps the login between runs. It
 * never touches the default Chrome profile.
 * @returns {object} Playwright persistent browser context
 */
export async function openSession() {
  return await chromium.launchPersistentContext(PROFILE_DIRECTORY, {
    channel: 'chrome',
    headless: false,
    // Google refuses to sign in a browser that announces it is automated
    ignoreDefaultArgs: ['--enable-automation'],
    args: ['--disable-blink-features=AutomationControlled'],
  });
}
