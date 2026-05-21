export default {
  '{scripts/bin,config/term/zsh}/**/*': [
    './scripts/yarn/test-bats',
    './scripts/yarn/lint-zsh',
  ],
  'scripts/bin/**/*.js': [
    'yarn run lint:fix --js',
    'yarn run test --fail-fast --related',
  ],
};
