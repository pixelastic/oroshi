// Key handler of the prompt input. Its branch on the key name accepts the
// suggestion, when one is shown and the input is empty. It is identified by
// its stable tokens, never by the minified variable names.
// Capture 1 is the event variable, capture 2 the key name test: the original
// "right", or the patched "down" followed by one space of padding.
export const SUGGESTION_HANDLER_REGEXP = new RegExp(
  String.raw`handleKeyDown:\(([\w$]+)\)=>\{if\(\1\.name===("right"|"down" )&&[^}]*?===""\)\{[^}]*?\1\.preventDefault\(\),\1\.stopImmediatePropagation\(\)`,
  'd',
);
export const ORIGINAL_KEY = '"right"';
export const PATCHED_KEY = '"down" ';
