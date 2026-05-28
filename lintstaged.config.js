export default {
  // zsh tests + lint
  '{scripts/bin,config/term/zsh}/**/*': [
    './scripts/yarn/test-bats',
    './scripts/yarn/lint-zsh',
  ],
  // JS tests + lint
  'scripts/bin/**/*.js': [
    'yarn run lint:fix --js',
    'yarn run test --fail-fast --related',
  ],
  // Regenerate projects.json and projects.zsh
  'tools/term/zsh/config/theming/src/{projects.json,projects-build}': [
    './tools/term/zsh/config/theming/src/projects-build',
  ],
};
