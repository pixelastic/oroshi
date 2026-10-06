import { suggestionPatch } from '../suggestionPatch.js';

describe('suggestionPatch', () => {
  const original =
    'AAAhandleKeyDown:(br)=>{if(br.name==="right"&&!Do){if(LEe(Wo)&&Ie===""){_e(),br.preventDefault(),br.stopImmediatePropagation();return}}BBB';

  it('reports an original text as not patched', () => {
    expect(suggestionPatch.isPatched(original)).toEqual(false);
  });

  it('patches the key and returns its offset', () => {
    const actual = suggestionPatch.patch(original);
    const offset = original.indexOf('"right"');
    expect(actual).toEqual({
      text: original.replace('"right"', '"down" '),
      offsets: [offset],
    });
    expect(suggestionPatch.isPatched(actual.text)).toEqual(true);
  });

  it('returns a patched text unchanged, without offsets', () => {
    const { text } = suggestionPatch.patch(original);
    const actual = suggestionPatch.patch(text);
    expect(actual).toEqual({ text, offsets: [] });
  });
});
