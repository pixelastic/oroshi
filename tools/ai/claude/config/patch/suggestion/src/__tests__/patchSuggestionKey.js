import { patchSuggestionKey } from '../patchSuggestionKey.js';
import { PATCHED_KEY } from '../suggestionHandler.js';

describe('patchSuggestionKey', () => {
  const installedHandler =
    'handleKeyDown:(br)=>{if(br.name==="right"&&!Do){if(LEe(Wo)&&Ie===""){_e(),Fs(Wo.text),br.preventDefault(),br.stopImmediatePropagation();return}}';
  const renamedHandler =
    'handleKeyDown:(q$)=>{if(q$.name==="right"&&!a1){if(Zx(m2)&&Qz===""){u(),k_(m2.text),q$.preventDefault(),q$.stopImmediatePropagation();return}}';
  const unrelatedRightHandler =
    'handleKeyDown:(e)=>{if(e.name==="right"&&!t){n(),e.preventDefault();return}}';
  const wrap = (handler) => `AAA${unrelatedRightHandler}BBB${handler}CCC`;

  describe('handler in original form', () => {
    it.each([
      { title: 'installed names', handler: installedHandler },
      { title: 'renamed names', handler: renamedHandler },
    ])('keeps the length with $title', ({ handler }) => {
      const input = wrap(handler);
      const actual = patchSuggestionKey(input).text;
      expect(actual).toHaveLength(input.length);
    });

    it.each([
      {
        title: 'installed names',
        handler: installedHandler,
        expected: installedHandler.replace('"right"', '"down" '),
      },
      {
        title: 'renamed names',
        handler: renamedHandler,
        expected: renamedHandler.replace('"right"', '"down" '),
      },
    ])('replaces right by down with $title', ({ handler, expected }) => {
      const actual = patchSuggestionKey(wrap(handler)).text;
      expect(actual).toEqual(wrap(expected));
    });

    it('returns the offset of the replaced key name', () => {
      const input = wrap(installedHandler);
      const { text, offset } = patchSuggestionKey(input);
      const actual = text.slice(offset, offset + PATCHED_KEY.length);
      expect(actual).toEqual(PATCHED_KEY);
    });
  });

  describe('already patched', () => {
    it('returns the same text', () => {
      const firstPass = patchSuggestionKey(wrap(installedHandler));
      const actual = patchSuggestionKey(firstPass.text);
      expect(actual).toEqual(firstPass);
    });
  });

  describe('handler missing', () => {
    it.each([
      { title: 'no handler', input: 'AAA BBB' },
      { title: 'only an unrelated right handler', input: wrap('') },
    ])('throws with $title', ({ input }) => {
      let actual = null;
      try {
        patchSuggestionKey(input);
      } catch (error) {
        actual = error;
      }
      expect(actual).toHaveProperty(
        'code',
        'CLAUDE_SUGGESTION_PATCH_HANDLER_NOT_FOUND',
      );
    });
  });
});
