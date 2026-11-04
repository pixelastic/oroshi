import hljs from 'highlight.js/lib/core';
import { patchTreeGrammar } from '../patchTreeGrammar.js';

describe('patchTreeGrammar', () => {
  const cedar =
    'var ZR=(e)=>({name:"Cedar",aliases:["cedarpolicy"],keywords:{keyword:"permit forbid when unless if then else in has like is",built_in:"principal action resource context decimal ip contains containsAll containsAny",literal:"true false"},contains:[e.QUOTE_STRING_MODE,e.C_NUMBER_MODE,e.C_LINE_COMMENT_MODE,{className:"meta",begin:/@\\w+/},{className:"type",begin:/\\b[A-Z]\\w*(::[A-Z]\\w*)*/}]}),uh=ZR;var d4r={cedar:uh},WKo=new Set(["cedarpolicy"]),_wn={cedar:"Cedar",cedarpolicy:"Cedar"};';
  const input = `AAA${cedar}BBB`;

  /**
   * Register the patched grammar in highlight.js, like Claude Code does
   * @param {string} text - Patched text
   * @returns {object} highlight.js instance with the tree language
   */
  function registerTree(text) {
    const factory = text.match(/ZR=(\(e\)=>.*?),uh=ZR/)[1];
    const grammar = new Function(`return ${factory}`)();
    const instance = hljs;
    instance.registerLanguage('tree', grammar);
    return instance;
  }

  it('replaces the Cedar grammar by the tree one', () => {
    const { text } = patchTreeGrammar(input);
    expect(text).toContain(
      'var d4r={tree:uh},WKo=new Set([]),_wn={tree:"Tree"};',
    );
    expect(text).not.toContain('Cedar');
  });

  it('keeps the exact same length', () => {
    const { text } = patchTreeGrammar(input);
    expect(text).toHaveLength(input.length);
  });

  it('returns the offset of the grammar', () => {
    const { offset } = patchTreeGrammar(input);
    expect(offset).toEqual(input.indexOf('ZR=(e)'));
  });

  it('is idempotent', () => {
    const firstPass = patchTreeGrammar(input).text;
    const actual = patchTreeGrammar(firstPass);
    expect(actual).toEqual(patchTreeGrammar(input));
  });

  it('only contains ASCII, as the binary is handled as latin1', () => {
    const { text } = patchTreeGrammar(input);
    expect(text).toMatch(/^[\x20-\x7e]*$/);
  });

  it('throws when the Cedar grammar is missing', () => {
    let actual = null;
    try {
      patchTreeGrammar('AAA');
    } catch (error) {
      actual = error;
    }
    expect(actual).toHaveProperty(
      'code',
      'CLAUDE_SYNTAX_PATCH_TREE_GRAMMAR_NOT_FOUND',
    );
  });

  it.each([
    {
      title: 'Branch markers',
      code: '│   ├── ',
      expected: '<span class="hljs-branch">│</span>',
    },
    {
      title: 'Folder',
      code: '├── src/\n',
      expected: '<span class="hljs-dir">src/</span>',
    },
    {
      title: 'File',
      code: '└── main.js\n',
      expected: '<span class="hljs-file">main.js</span>',
    },
    {
      title: 'Comment',
      code: '├── src/  # Sources\n',
      expected: '<span class="hljs-comment"># Sources</span>',
    },
  ])('highlights: $title', ({ code, expected }) => {
    const { text } = patchTreeGrammar(input);
    const instance = registerTree(text);
    const actual = instance.highlight(code, { language: 'tree' }).value;
    expect(actual).toContain(expected);
  });
});
