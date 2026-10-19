import { run } from 'firost';

export let __;

/**
 * Write a text to the clipboard with the clipboard-write helper
 * clipboard-write is a ZSH function, so it is called through zsh. It rejects
 * when the helper fails. The previous clipboard is neither read nor restored.
 * @param {string} text - Text to put in the clipboard
 */
export async function writeClipboard(text) {
  await __.run(['zsh', '-c', 'clipboard-write'], {
    input: text,
    stdout: false,
    stderr: false,
  });
}

__ = {
  run,
};
