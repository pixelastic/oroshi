module.exports = {
  env: {
    browser: true,
    es6: true,
    node: true,
    jest: true,
  },
  parserOptions: {
    ecmaVersion: 2018,
  },
  extends: [
    'eslint:recommended',
  ],
  rules: {
    'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
  },
};
