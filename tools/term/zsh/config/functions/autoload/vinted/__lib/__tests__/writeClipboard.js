import { __, writeClipboard } from '../writeClipboard.js';

describe('writeClipboard', () => {
  it('sends the text to clipboard-write on stdin', async () => {
    vi.spyOn(__, 'run').mockReturnValue({ stdout: '', stderr: '' });
    const input = 'first line\nsecond line';

    await writeClipboard(input);

    expect(__.run).toHaveBeenCalledWith(['zsh', '-c', 'clipboard-write'], {
      input,
      stdout: false,
      stderr: false,
    });
  });

  it('rejects when clipboard-write fails', async () => {
    vi.spyOn(__, 'run').mockImplementation(() => {
      throw new Error('wl-copy missing');
    });

    let actual = null;
    try {
      await writeClipboard('text');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'wl-copy missing');
  });
});
