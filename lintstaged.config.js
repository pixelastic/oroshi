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

  // JS Scripts
  '**/*.js': ['yarn run lint:fix --js', 'yarn run test --fail-fast --related'],
  'scripts/yarn/**/*': ['yarn run lint:zsh'],

  // Colors reload
  'tools/term/zsh/config/theming/**/{colors,filetypes,icons,projects}.jsonc':
    'yarn run colors-reload',
  'tools/term/zsh/config/functions/autoload/**/{colors,filetypes,icons,project}-build':
    'yarn run colors-reload',
};
