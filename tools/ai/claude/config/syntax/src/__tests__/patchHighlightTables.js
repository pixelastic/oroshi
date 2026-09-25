import { patchHighlightTables } from '../patchHighlightTables.js';

describe('patchHighlightTables', () => {
  const diffTable =
    'var j=new Map([["keyword",l(249,38,114)],["_storage",l(102,217,239)],["title.function",l(166,226,46)],["comment",l(117,113,94)],["meta",l(117,113,94)],["variable",l(255,255,255)],["operator",l(249,38,114)]])';
  const lightTable = ',G=new Map([["keyword",l(167,29,93)]]);';
  const codeTable =
    'var a=new Map(Object.entries({keyword:de.blue,string:de.red,subst:de.reset,"title.function":de.yellow,meta:de.grey,"meta-keyword":de.reset,"meta.keyword":de.reset,bullet:de.reset,code:de.reset,quote:de.reset,emphasis:de.italic}));function u(e){let t=e.replace(/^hljs-/,"");}';
  const decorationTable =
    'if(t){let m=l(248,248,242),b=l(61,1,0),g=l(92,2,0),y=l(220,90,90);if(r)return{addLine:s?l(0,27,41):x(17),addDecoration:l(81,160,200),deleteDecoration:y};return{addLine:s?l(2,40,0):x(22),addWord:s?l(4,71,0):x(28),addDecoration:l(80,200,80),deleteLine:b,deleteDecoration:y}}';
  const input = `AAA${diffTable}${lightTable}BBB${codeTable}CCC${decorationTable}DDD`;
  const decorationColors = { added: '#276749', removed: '#7f1d1d' };
  const scopeColors = {
    keyword: '#38a169',
    'title.function': '#d69e2e',
    string: '#3182ce',
  };

  it('keeps the exact same length', () => {
    const actual = patchHighlightTables(input, scopeColors);
    expect(actual.text).toHaveLength(input.length);
  });

  it('patches the diff table, keeping unresolved scopes', () => {
    const actual = patchHighlightTables(input, scopeColors);
    const expected =
      'var j=new Map(Object.entries({keyword:l(56,161,105),_storage:l(102,217,239),"title.function":l(214,158,46),comment:l(117,113,94),meta:l(117,113,94),variable:l(255,255,255),operator:l(249,38,114)}))';
    expect(actual.text).toContain(expected);
    expect(actual.text).toContain(lightTable);
  });

  it('patches the code block table, keeping unresolved scopes and dropping top-level resets', () => {
    const actual = patchHighlightTables(input, scopeColors);
    const expected =
      'var a=new Map(Object.entries({keyword:"38a169",string:"3182ce","title.function":"d69e2e",meta:de.grey,"meta.keyword":de.reset,emphasis:de.italic}).map(([k,v])=>[k,typeof v=="string"?de.hex("#"+v):v]))';
    expect(actual.text).toContain(expected);
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
    expect(actual).toContain('keyword:"ff0000"');
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
