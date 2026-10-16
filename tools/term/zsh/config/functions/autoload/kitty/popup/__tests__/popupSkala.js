import { __, popupSkala } from '../__lib/popupSkala.js';

describe('popupSkala', () => {
  beforeEach(() => {
    vi.spyOn(__, 'run').mockReturnValue({});
    vi.spyOn(__, 'popupPrompt');
    vi.spyOn(__, 'popupError').mockReturnValue();
  });

  it('adds the typed command to the allowlist', async () => {
    __.popupPrompt.mockReturnValue('ls -la');

    const actual = await popupSkala();

    expect(actual).toEqual(true);
    expect(__.run).toHaveBeenCalledWith([
      'bin-zsh',
      'skills-allowlist-add',
      'ls -la',
    ]);
  });

  it.each([
    { title: 'cancelled', input: null },
    { title: 'empty', input: '' },
  ])('adds nothing when $title', async ({ input }) => {
    __.popupPrompt.mockReturnValue(input);

    const actual = await popupSkala();

    expect(actual).toEqual(false);
    expect(__.run).not.toHaveBeenCalled();
  });

  it('keeps the error visible when the add fails', async () => {
    __.popupPrompt.mockReturnValue('ls -la');
    __.run.mockImplementation(() => {
      throw new Error('failed');
    });

    const actual = await popupSkala();

    expect(actual).toEqual(false);
    expect(__.popupError).toHaveBeenCalledWith(
      'Could not add to allowlist: ls -la',
    );
  });
});
