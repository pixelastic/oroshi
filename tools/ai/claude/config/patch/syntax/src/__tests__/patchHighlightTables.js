import { _ } from 'golgoth';
import { PATCH_MARKER, patchHighlightTables } from '../patchHighlightTables.js';

describe('patchHighlightTables', () => {
  const diffTable =
    'var j=new Map([["keyword",l(249,38,114)],["_storage",l(102,217,239)],["title.function",l(166,226,46)],["comment",l(117,113,94)],["meta",l(117,113,94)],["variable",l(255,255,255)],["number",l(174,129,255)],["attr",l(166,226,46)],["built_in",l(102,217,239)],["operator",l(249,38,114)]])';
  const lightTable = ',G=new Map([["keyword",l(167,29,93)]]);';
  const codeTable =
    'var a=new Map(Object.entries({keyword:fe.blue,built_in:fe.cyan,type:fe.red,literal:fe.yellow,number:fe.cyan,regexp:fe.red,string:fe.red,subst:fe.reset,symbol:fe.red,class:fe.yellow,function:fe.yellow,title:fe.yellow,"title.function":fe.yellow,"title.class":fe.yellow,params:fe.reset,comment:fe.grey,doctag:fe.grey,meta:fe.grey,"meta.keyword":fe.reset,"meta.string":fe.reset,section:"b794f4",tag:"f87171",name:"f87171",attr:"c4b5fd",attribute:"c4b5fd",variable:"a78bfa",bullet:fe.reset,code:fe.reset,quote:fe.reset,emphasis:fe.italic,strong:fe.bold,link:fe.underline,addition:fe.green,deletion:fe.red}))                                                                                                    ;function u(e){let t=e.replace(/^hljs-/,"");}';
  const decorationTable =
    'if(t){let m=l(248,248,242),b=l(61,1,0),g=l(92,2,0),y=l(220,90,90);if(r)return{addLine:s?l(0,27,41):x(17),addDecoration:l(81,160,200),deleteDecoration:y};return{addLine:s?l(2,40,0):x(22),addWord:s?l(4,71,0):x(28),addDecoration:l(80,200,80),deleteLine:b,deleteDecoration:y}}';
  const input = `AAA${diffTable}${lightTable}BBB${codeTable}CCC${decorationTable}DDD`;
  const decorationColors = { added: '#276749', removed: '#7f1d1d' };
  const scopeColors = {
    keyword: '#38a169',
    'title.function': '#d69e2e',
    string: '#3182ce',
  };

  describe('marker', () => {
    it('is exported with its expected value', () => {
      expect(PATCH_MARKER).toEqual('/*oroshi-patched*/');
    });

    it('is written once after the diff table', () => {
      const actual = patchHighlightTables(input, scopeColors).text;
      expect(actual.split(PATCH_MARKER)).toHaveLength(2);
      expect(actual).toContain(`}))${PATCH_MARKER}`);
    });

    it('patches an already patched text', () => {
      const firstPass = patchHighlightTables(input, scopeColors).text;
      const actual = patchHighlightTables(firstPass, scopeColors);
      expect(actual).toHaveProperty('text', firstPass);
    });

    it('applies new colors when patching an already patched text', () => {
      const firstPass = patchHighlightTables(input, scopeColors).text;
      const actual = patchHighlightTables(firstPass, {
        ...scopeColors,
        keyword: '#ff0000',
      }).text;
      expect(actual).toContain('keyword:l(255,0,0)');
    });

    it('appears once after a repatch', () => {
      const firstPass = patchHighlightTables(input, scopeColors).text;
      const actual = patchHighlightTables(firstPass, scopeColors).text;
      expect(actual.split(PATCH_MARKER)).toHaveLength(2);
    });

    it('throws when the padding cannot hold it', () => {
      const firstPass = patchHighlightTables(input, scopeColors).text;
      const withoutRoom = firstPass.replace(
        new RegExp(`${_.escapeRegExp(PATCH_MARKER)} *`),
        '',
      );
      let actual = null;
      try {
        patchHighlightTables(withoutRoom, scopeColors);
      } catch (error) {
        actual = error;
      }
      expect(actual).toHaveProperty('code', 'CLAUDE_SYNTAX_PATCH_TOO_LONG');
    });
  });

  it('keeps the exact same length', () => {
    const actual = patchHighlightTables(input, scopeColors);
    expect(actual.text).toHaveLength(input.length);
  });

  it('patches the diff table, keeping unresolved scopes', () => {
    const actual = patchHighlightTables(input, scopeColors);
    const expected =
      'var j=new Map(Object.entries({keyword:l(56,161,105),_storage:l(102,217,239),"title.function":l(214,158,46),comment:l(117,113,94),meta:l(117,113,94),variable:l(255,255,255),number:l(174,129,255),attr:l(166,226,46),built_in:l(102,217,239),operator:l(249,38,114)}))';
    expect(actual.text).toContain(expected);
    expect(actual.text).toContain(lightTable);
  });

  it('patches the code block table, keeping unresolved scopes and dropping top-level resets', () => {
    const actual = patchHighlightTables(input, scopeColors);
    const expected =
      'var a=new Map(Object.entries({"38a169":"keyword","3182ce":"string","d69e2e":"title.function","b794f4":"section","f87171":"tag name","c4b5fd":"attr attribute","a78bfa":"variable"}).flatMap(([h,s])=>s.split(" ").map(k=>[k,fe.hex("#"+h)])).concat(Object.entries({built_in:fe.cyan,type:fe.red,literal:fe.yellow,number:fe.cyan,regexp:fe.red,symbol:fe.red,class:fe.yellow,function:fe.yellow,title:fe.yellow,"title.class":fe.yellow,comment:fe.grey,doctag:fe.grey,meta:fe.grey,"meta.keyword":fe.reset,"meta.string":fe.reset,emphasis:fe.italic,strong:fe.bold,link:fe.underline,addition:fe.green,deletion:fe.red})))';
    expect(actual.text).toContain(expected);
  });

  it('adds the tree scopes to the code block table', () => {
    const actual = patchHighlightTables(input, {
      ...scopeColors,
      dir: '#00ff00',
    });
    expect(actual.text).toContain('"00ff00":"dir"}).flatMap(');
    expect(actual.text).toHaveLength(input.length);
  });

  it('does not duplicate the tree scopes when patching again', () => {
    const colors = { ...scopeColors, dir: '#00ff00' };
    const firstPass = patchHighlightTables(input, colors).text;
    const actual = patchHighlightTables(firstPass, colors).text;
    expect(actual.match(/\bdir\b/g)).toHaveLength(1);
  });

  it('removes duplicated scopes left by a previous patch', () => {
    const colors = { ...scopeColors, dir: '#00ff00' };
    const firstPass = patchHighlightTables(input, colors).text;
    const duplicated = firstPass.replace('"dir"', '"dir dir"');
    const actual = patchHighlightTables(duplicated, colors).text;
    expect(actual.match(/\bdir\b/g)).toHaveLength(1);
  });

  it('does not add the tree scopes to the diff table', () => {
    const actual = patchHighlightTables(input, {
      ...scopeColors,
      dir: '#00ff00',
    });
    expect(actual.text.match(/\bdir\b/g)).toHaveLength(1);
  });

  it('patches the diff line number and marker colors, padding shorter values', () => {
    const actual = patchHighlightTables(input, scopeColors, decorationColors);
    const expected =
      'if(t){let m=l(248,248,242),b=l(61,1,0),g=l(92,2,0),y=l(127,29,29);if(r)return{addLine:s?l(0,27,41):x(17),addDecoration:l(81,160,200),deleteDecoration:y};return{addLine:s?l(2,40,0):x(22),addWord:s?l(4,71,0):x(28),addDecoration:l(39,103,73),deleteLine:b,deleteDecoration:y}}';
    expect(actual.text).toContain(expected);
    expect(actual.text).toHaveLength(input.length);
  });

  it('pads shorter decoration colors inside the call', () => {
    const actual = patchHighlightTables(input, scopeColors, {
      added: '#010203',
    });
    expect(actual.text).toContain('addDecoration:l(1,2,3    ),deleteLine');
    expect(actual.text).toContain('y=l(220,90,90);');
  });

  it('returns the offset of each patched table', () => {
    const actual = patchHighlightTables(input, scopeColors);
    const expected = [
      input.indexOf('new Map([["keyword"'),
      input.indexOf('new Map(Object.entries'),
      input.indexOf('let m=l(248,248,242)'),
    ];
    expect(actual).toHaveProperty('offsets', expected);
  });

  it('is idempotent', () => {
    const firstPass = patchHighlightTables(
      input,
      scopeColors,
      decorationColors,
    ).text;
    const actual = patchHighlightTables(
      firstPass,
      scopeColors,
      decorationColors,
    );
    const expected = patchHighlightTables(input, scopeColors, decorationColors);
    expect(actual).toEqual(expected);
  });

  it('can change colors of an already patched text', () => {
    const firstPass = patchHighlightTables(input, scopeColors).text;
    const actual = patchHighlightTables(firstPass, {
      ...scopeColors,
      keyword: '#ff0000',
    }).text;
    expect(actual).toContain('keyword:l(255,0,0)');
    expect(actual).toContain('"ff0000":"keyword"');
  });

  it.each([
    { title: 'Diff table', text: `AAA${codeTable}` },
    { title: 'Code block table', text: `AAA${diffTable}${lightTable}` },
    {
      title: 'Decoration table',
      text: `AAA${diffTable}${lightTable}${codeTable}`,
    },
  ])('throws when a table is missing: $title', ({ text }) => {
    let actual = null;
    try {
      patchHighlightTables(text, scopeColors);
    } catch (error) {
      actual = error;
    }
    expect(actual).toHaveProperty(
      'code',
      'CLAUDE_SYNTAX_PATCH_TABLE_NOT_FOUND',
    );
  });

  it.each([
    {
      title: 'Diff table',
      text: `var j=new Map([["keyword",l(1,1,1)]])${lightTable}${codeTable}${decorationTable}`,
      colors: [{ keyword: '#ffffff' }],
    },
    {
      title: 'Decoration color',
      text: input,
      colors: [scopeColors, { added: '#ffffff' }],
    },
  ])(
    'throws when the patched table would be longer: $title',
    ({ text, colors }) => {
      let actual = null;
      try {
        patchHighlightTables(text, ...colors);
      } catch (error) {
        actual = error;
      }
      expect(actual).toHaveProperty('code', 'CLAUDE_SYNTAX_PATCH_TOO_LONG');
    },
  );
});
