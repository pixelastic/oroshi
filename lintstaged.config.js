export default {
  // TEST+LINT: Binary zsh scripts
  'scripts/bin/**/*': ['yarn run test:bats', 'yarn run lint:zsh'],
  // TEST+LINT: Binary JS scripts
  'scripts/bin/**/*.js': [
    'yarn run lint:fix --js',
    'yarn run test --fail-fast --related',
  ],

  // LINT: yarn run * scripts
  'scripts/yarn/**/*': ['yarn run lint:zsh'],

  // LINT: Install/Deploy scripts
  'tools/**/*': ['yarn run lint:zsh'],

  // TEST: Zsh autoloaded functions
  'tools/term/zsh/config/**/*': ['yarn run test:bats'],

  // BUILD: projects.json and projects.zsh
  'tools/term/zsh/config/theming/src/projects.json': [
    './tools/term/zsh/config/theming/projects-build',
  ],
  'tools/term/zsh/config/theming/projects-build': [
    './tools/term/zsh/config/theming/projects-build',
  ],
};
