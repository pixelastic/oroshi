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

  // JS Scripts
  'scripts/bin/**/*.js': [
    'yarn run lint:fix --js',
    'yarn run test --fail-fast --related',
  ],
  'scripts/yarn/**/*': ['yarn run lint:zsh'],

  // BUILD: projects.json and projects.zsh
  'tools/term/zsh/config/theming/src/projects.json': [
    './tools/term/zsh/config/theming/projects-build',
  ],
  'tools/term/zsh/config/theming/projects-build': [
    './tools/term/zsh/config/theming/projects-build',
  ],
};
