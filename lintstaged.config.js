export default {
  // ZSH scripts
  'scripts/bin/**/*': ['yarn run test:bats', 'yarn run lint:zsh'],
  'tools/ai/claude/config/hooks/**/*': [
    'yarn run test:bats',
    'yarn run lint:zsh',
  ],
  'tools/term/zsh/config/**/*': ['yarn run test:bats'],
  'tools/**/*': ['yarn run lint:zsh'],

  // Bats test files
  '{**/*.bats,tools/term/bats/config/*}': ['yarn run lint:bats'],

  // Python files
  '**/*.py': ['yarn run lint:python', 'yarn run test:python'],

  // Go files
  '**/*.go': ['yarn precommit:lint go', 'yarn precommit:test go'],

  // JSON files
  '**/*.json': ['yarn precommit:lint json'],

  // JS Scripts
  '**/*.js': ['yarn run lint:fix --js', 'yarn run test --fail-fast --related'],
  'scripts/yarn/**/*': ['yarn run lint:zsh'],

  // Vale profiles rebuild
  'tools/prose/vale/src/*.ini': 'yarn run prose-build',

  // Colors rebuild + stage dist
  'tools/term/zsh/config/theming/**/{colors,filetypes,icons,projects}.jsonc':
    'yarn run colors-build-and-stage',
  'tools/term/zsh/config/functions/autoload/**/{colors,filetypes,icons,project}-build':
    'yarn run colors-build-and-stage',
};
