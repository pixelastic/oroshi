export default {
  // ZSH scripts
  'scripts/bin/**/*': ['yarn precommit:test zsh', 'yarn precommit:lint zsh'],
  'tools/ai/claude/config/hooks/**/*': [
    'yarn precommit:test zsh',
    'yarn precommit:lint zsh',
  ],
  'tools/term/zsh/config/**/*': ['yarn precommit:test zsh'],
  'tools/**/*': ['yarn precommit:lint zsh'],

  // Bats test files
  '{**/*.bats,tools/term/bats/config/*}': ['yarn run lint:bats'],

  // Python files
  '**/*.py': ['yarn precommit:lint python', 'yarn precommit:test python'],

  // Go files
  '**/*.go': ['yarn precommit:lint go', 'yarn precommit:test go'],

  // JSON files
  '**/*.json': ['yarn precommit:lint json'],

  // TOML files
  '**/*.toml': ['yarn precommit:lint toml'],

  // SVG files
  '**/*.svg': ['yarn precommit:lint svg'],

  // XML files
  '**/*.xml': ['yarn precommit:lint xml'],

  // JS Scripts
  '**/*.{js,mjs,cjs,jsx,vue}': [
    'yarn precommit:lint js',
    'yarn precommit:test js',
  ],
  'scripts/yarn/**/*': ['yarn precommit:lint zsh'],

  // Vale profiles rebuild
  'tools/prose/vale/src/*.ini': 'yarn run prose-build',

  // Colors rebuild + stage dist
  'tools/term/zsh/config/theming/**/{colors,filetypes,icons,projects}.jsonc':
    'yarn run colors-build-and-stage',
  'tools/term/zsh/config/functions/autoload/**/{colors,filetypes,icons,project}-build':
    'yarn run colors-build-and-stage',
  'tools/vim/nvim/config/lua/oroshi/colorscheme/syntax.lua':
    'yarn run colors-build-and-stage',

  // Claude Code syntax colors patch (binary is not committed, nothing to stage)
  'tools/ai/claude/config/syntax/**/*':
    './tools/ai/claude/config/syntax/generate-syntax',

  // Claude Code UI theme (output is outside the repo, nothing to stage)
  'tools/ai/claude/config/themes/src/**/*':
    './tools/ai/claude/config/themes/generate-theme',
};
