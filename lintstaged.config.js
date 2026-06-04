export default {
  // TEST+LINT: Binary zsh scripts
  'scripts/bin/**/*': ['./scripts/yarn/test-bats', './scripts/yarn/lint-zsh'],
  // TEST+LINT: Binary JS scripts
  'scripts/bin/**/*.js': [
    'yarn run lint:fix --js',
    'yarn run test --fail-fast --related',
  ],

  // LINT: yarn run * scripts
  'scripts/yarn/**/*': ['./scripts/yarn/hooks/pre-commit-zsh-lint'],

  // LINT: Install/Deploy scripts
  'tools/**/*': ['./scripts/yarn/lint-zsh'],

  // TEST: Zsh autoloaded functions
  'tools/term/zsh/config/**/*': ['./scripts/yarn/test-bats'],

  // BUILD: projects.json and projects.zsh
  'tools/term/zsh/config/theming/src/projects.json': [
    './tools/term/zsh/config/theming/projects-build',
  ],
  'tools/term/zsh/config/theming/projects-build': [
    './tools/term/zsh/config/theming/projects-build',
  ],
};
