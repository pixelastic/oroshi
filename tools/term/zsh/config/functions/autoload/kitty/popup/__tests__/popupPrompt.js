import { __, popupPrompt } from '../__lib/popupPrompt.js';

describe('popupPrompt', () => {
  it.each([
    { title: 'trims the answer', answer: '  ls -la  ', expected: 'ls -la' },
    { title: 'keeps an empty answer', answer: '', expected: '' },
  ])('$title', async ({ answer, expected }) => {
    vi.spyOn(__, 'prompt').mockReturnValue(answer);

    const actual = await popupPrompt('Question:');

    expect(actual).toEqual(expected);
  });

  it('returns null on Ctrl-C', async () => {
    const error = new Error('User pressed Ctrl-C during prompt');
    error.code = 'FIROST_PROMPT_CTRL_C';
    vi.spyOn(__, 'prompt').mockImplementation(() => {
      throw error;
    });

    const actual = await popupPrompt('Question:');

    expect(actual).toEqual(null);
  });

  it('rethrows any other error', async () => {
    vi.spyOn(__, 'prompt').mockImplementation(() => {
      throw new Error('boom');
    });

    let actual = null;
    try {
      await popupPrompt('Question:');
    } catch (err) {
      actual = err;
    }

    expect(actual).toHaveProperty('message', 'boom');
  });
});
