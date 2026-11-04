import { firostError } from 'firost';

// Scopes emitted by the tree grammar that Claude Code does not color. They are
// added to the code block table. The comments reuse the comment scope. The
// table has little room left, so short names are required.
export const TREE_SCOPES = ['branch', 'dir', 'file'];

// Box drawing characters (│ ├ └ ─), as escapes: the binary is handled as
// latin1, so the source must stay ASCII
const BRANCH = String.raw`\u2502\u251c\u2514\u2500`;

// Cedar policy grammar, unlikely to be used. Its function, its entry in the
// built-in languages table, and its alias and name entries are replaced.
// Names are minified, so they are captured.
const CEDAR_REGEXP =
  /([\w$]+)=\(e\)=>\(\{name:"Cedar",[^;]*?,([\w$]+)=\1;var ([\w$]+)=\{cedar:\2\},([\w$]+)=new Set\(\["cedarpolicy"\]\),([\w$]+)=\{cedar:"Cedar",cedarpolicy:"Cedar"\};/;
// Same, once replaced by a previous patch
const TREE_REGEXP =
  /([\w$]+)=\(e\)=>\(\{name:"Tree",[^;]*?,([\w$]+)=\1;var ([\w$]+)=\{tree:\2\},([\w$]+)=new Set\(\[\]\),([\w$]+)=\{tree:"Tree"\};/;

export let __;

/**
 * Replace the Cedar grammar of Claude Code by a `tree` grammar, to color file
 * trees. The output has the exact same length as the input, so it can be
 * written back into the binary without moving any offset.
 * @param {string} text - Binary content, as a latin1 string
 * @returns {{text: string, offset: number}} Patched text and offset of the grammar
 */
export function patchTreeGrammar(text) {
  const match = text.match(CEDAR_REGEXP) || text.match(TREE_REGEXP);
  if (!match) {
    throw firostError(
      'CLAUDE_SYNTAX_PATCH_TREE_GRAMMAR_NOT_FOUND',
      'Could not find the Cedar grammar to replace by the tree grammar',
    );
  }

  const [original] = match;
  const replacement = __.buildGrammar(match);
  if (replacement.length > original.length) {
    throw firostError(
      'CLAUDE_SYNTAX_PATCH_TREE_GRAMMAR_TOO_LONG',
      `Tree grammar is ${replacement.length - original.length} chars too long`,
    );
  }

  return {
    text:
      text.slice(0, match.index) +
      replacement.padEnd(original.length, ' ') +
      text.slice(match.index + original.length),
    offset: match.index,
  };
}

__ = {
  /**
   * Build the tree grammar and the tables registering it
   * @param {Array} match - CEDAR_REGEXP match
   * @returns {string} Replacement code
   */
  buildGrammar(match) {
    const [, grammar, alias, languages, aliases, names] = match;
    const marker = `[^\\s#${BRANCH}]`;
    const modes = [
      '{className:"comment",begin:/#/,end:/$/}',
      `{className:"branch",begin:/[${BRANCH}]+/}`,
      `{className:"dir",begin:/${marker}+\\/(?=\\s|$)/}`,
      `{className:"file",begin:/${marker}+/}`,
    ];

    return [
      `${grammar}=(e)=>({name:"Tree",contains:[${modes.join(',')}]}),${alias}=${grammar};`,
      `var ${languages}={tree:${alias}},${aliases}=new Set([]),${names}={tree:"Tree"};`,
    ].join('');
  },
};
