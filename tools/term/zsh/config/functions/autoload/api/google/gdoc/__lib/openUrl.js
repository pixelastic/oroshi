import { run } from 'firost';

export let __;

/**
 * Open a URL in the default browser, without waiting for it
 * @param {string} url - URL to open
 * @returns {Promise<void>} Resolves once the browser is started
 */
export async function openUrl(url) {
  await __.run(['xdg-open', url], { detached: true });
}

__ = {
  run,
};
