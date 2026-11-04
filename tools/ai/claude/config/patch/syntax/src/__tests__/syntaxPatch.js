import { syntaxPatch } from '../syntaxPatch.js';

describe('syntaxPatch', () => {
  const diffTable =
    'var j=new Map([["keyword",l(249,38,114)],["_storage",l(102,217,239)],["title.function",l(166,226,46)],["comment",l(117,113,94)],["meta",l(117,113,94)],["variable",l(255,255,255)],["number",l(174,129,255)],["attr",l(166,226,46)],["built_in",l(102,217,239)],["operator",l(249,38,114)]])';
  const lightTable = ',G=new Map([["keyword",l(167,29,93)]]);';
  const codeTable =
    'var a=new Map(Object.entries({keyword:fe.blue,built_in:fe.cyan,type:fe.red,literal:fe.yellow,number:fe.cyan,regexp:fe.red,string:fe.red,subst:fe.reset,symbol:fe.red,class:fe.yellow,function:fe.yellow,title:fe.yellow,"title.function":fe.yellow,"title.class":fe.yellow,params:fe.reset,comment:fe.grey,doctag:fe.grey,meta:fe.grey,"meta.keyword":fe.reset,"meta.string":fe.reset,section:"b794f4",tag:"f87171",name:"f87171",attr:"c4b5fd",attribute:"c4b5fd",variable:"a78bfa",bullet:fe.reset,code:fe.reset,quote:fe.reset,emphasis:fe.italic,strong:fe.bold,link:fe.underline,addition:fe.green,deletion:fe.red}))                                                                                                    ;function u(e){let t=e.replace(/^hljs-/,"");}';
  const decorationTable =
    'if(t){let m=l(248,248,242),b=l(61,1,0),g=l(92,2,0),y=l(220,90,90);if(r)return{addLine:s?l(0,27,41):x(17),addDecoration:l(81,160,200),deleteDecoration:y};return{addLine:s?l(2,40,0):x(22),addWord:s?l(4,71,0):x(28),addDecoration:l(80,200,80),deleteLine:b,deleteDecoration:y}}';
  const cedar =
    'var ZR=(e)=>({name:"Cedar",aliases:["cedarpolicy"],keywords:{keyword:"permit forbid when unless if then else in has like is",built_in:"principal action resource context decimal ip contains containsAll containsAny",literal:"true false"},contains:[e.QUOTE_STRING_MODE,e.C_NUMBER_MODE,e.C_LINE_COMMENT_MODE,{className:"meta",begin:/@\\w+/},{className:"type",begin:/\\b[A-Z]\\w*(::[A-Z]\\w*)*/}]}),uh=ZR;var d4r={cedar:uh},WKo=new Set(["cedarpolicy"]),_wn={cedar:"Cedar",cedarpolicy:"Cedar"};';
  const original = `AAA${diffTable}${lightTable}BBB${codeTable}CCC${decorationTable}DDD${cedar}EEE`;
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
      original.indexOf('new Map(Object.entries({keyword:fe.blue'),
      original.indexOf('let m=l(248'),
      original.indexOf('ZR=(e)'),
    ]);
    expect(actual.text).toContain('{tree:uh}');
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
