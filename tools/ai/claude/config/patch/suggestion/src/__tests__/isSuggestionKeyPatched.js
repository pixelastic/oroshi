import { isSuggestionKeyPatched } from '../isSuggestionKeyPatched.js';
import { patchSuggestionKey } from '../patchSuggestionKey.js';

describe('isSuggestionKeyPatched', () => {
  const handler =
    'handleKeyDown:(br)=>{if(br.name==="right"&&!Do){if(LEe(Wo)&&Ie===""){_e(),Fs(Wo.text),br.preventDefault(),br.stopImmediatePropagation();return}}';
  const input = `AAA${handler}BBB`;

  it('is false before patching', () => {
    const actual = isSuggestionKeyPatched(input);
    expect(actual).toEqual(false);
  });

  it('is true after patching', () => {
    const { text } = patchSuggestionKey(input);
    const actual = isSuggestionKeyPatched(text);
    expect(actual).toEqual(true);
  });
});
