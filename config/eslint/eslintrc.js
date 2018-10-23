/* eslint-disable import/no-commonjs */
module.exports = {
  extends: 'algolia',
  rules: {
    'no-console': ['error', { allow: ['warn', 'error'] }],
    'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
  },
};
