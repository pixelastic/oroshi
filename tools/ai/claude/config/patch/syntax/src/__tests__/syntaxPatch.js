import { syntaxPatch } from '../syntaxPatch.js';

describe('syntaxPatch', () => {
  const diffTable =
    'var j=new Map([["keyword",l(249,38,114)],["_storage",l(102,217,239)],["title.function",l(166,226,46)],["comment",l(117,113,94)],["meta",l(117,113,94)],["variable",l(255,255,255)],["number",l(174,129,255)],["attr",l(166,226,46)],["built_in",l(102,217,239)],["operator",l(249,38,114)]])';
  const lightTable = ',G=new Map([["keyword",l(167,29,93)]]);';
  const codeTable =
    'var a=new Map(Object.entries({keyword:de.blue,string:de.red,subst:de.reset,"title.function":de.yellow,meta:de.grey,"meta-keyword":de.reset,"meta.keyword":de.reset,bullet:de.reset,code:de.reset,quote:de.reset,emphasis:de.italic}));function u(e){let t=e.replace(/^hljs-/,"");}';
  const decorationTable =
    'if(t){let m=l(248,248,242),b=l(61,1,0),g=l(92,2,0),y=l(220,90,90);if(r)return{addLine:s?l(0,27,41):x(17),addDecoration:l(81,160,200),deleteDecoration:y};return{addLine:s?l(2,40,0):x(22),addWord:s?l(4,71,0):x(28),addDecoration:l(80,200,80),deleteLine:b,deleteDecoration:y}}';
  const original = `AAA${diffTable}${lightTable}BBB${codeTable}CCC${decorationTable}DDD`;
  const options = {
    scopeColors: { keyword: '#38a169', string: '#3182ce' },
    decorationColors: { added: '#276749', removed: '#7f1d1d' },
  };

  it('reports an original text as not patched', () => {
    expect(syntaxPatch.isPatched(original)).toEqual(false);
  });

  it('patches the tables with the given colors', () => {
    const actual = syntaxPatch.patch(original, options);
    expect(actual.text).toHaveLength(original.length);
    expect(actual.text).toContain('keyword:l(56,161,105)');
    expect(actual).toHaveProperty('offsets', [
      original.indexOf('new Map([["keyword",l(249'),
      original.indexOf('new Map(Object.entries({keyword:de.blue'),
      original.indexOf('let m=l(248'),
    ]);
    expect(syntaxPatch.isPatched(actual.text)).toEqual(true);
  });

  it('applies new colors to an already patched text', () => {
    const { text } = syntaxPatch.patch(original, options);
    const actual = syntaxPatch.patch(text, {
      ...options,
      scopeColors: { keyword: '#ff0000' },
    });
    expect(actual.text).toContain('keyword:l(255,0,0)');
  });
});
