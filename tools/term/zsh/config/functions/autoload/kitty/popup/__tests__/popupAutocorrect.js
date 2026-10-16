import { __, popupAutocorrect } from '../__lib/popupAutocorrect.js';

describe('popupAutocorrect', () => {
  beforeEach(() => {
    vi.spyOn(__, 'run').mockReturnValue({});
    vi.spyOn(__, 'popupPrompt');
    vi.spyOn(__, 'popupError').mockReturnValue();
  });

  it.each([
    { title: 'a replacement', wrong: 'eovim', right: 'NeoVim' },
    { title: 'a suppression', wrong: 'euh', right: '' },
  ])('adds the rule with $title', async ({ wrong, right }) => {
    __.popupPrompt.mockReturnValueOnce(wrong).mockReturnValueOnce(right);

    const actual = await popupAutocorrect();

    expect(actual).toEqual(true);
    expect(__.run).toHaveBeenCalledWith([
      'bin-zsh',
      'mic2txt-autocorrect-add',
      wrong,
      right,
    ]);
  });

  it.each([
    { title: 'the word is cancelled', answers: [null] },
    { title: 'the word is empty', answers: [''] },
    { title: 'the replacement is cancelled', answers: ['eovim', null] },
  ])('adds nothing when $title', async ({ answers }) => {
    __.popupPrompt
      .mockReturnValueOnce(answers[0])
      .mockReturnValueOnce(answers[1]);

    const actual = await popupAutocorrect();

    expect(actual).toEqual(false);
    expect(__.run).not.toHaveBeenCalled();
  });

  it('keeps the error visible when the add fails', async () => {
    __.popupPrompt.mockReturnValueOnce('eovim').mockReturnValueOnce('NeoVim');
    __.run.mockImplementation(() => {
      throw new Error('failed');
    });

    const actual = await popupAutocorrect();

    expect(actual).toEqual(false);
    expect(__.popupError).toHaveBeenCalledWith(
      'Could not add autocorrect rule: eovim → NeoVim',
    );
  });
});
