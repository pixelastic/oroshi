module.exports = {
  extends: ['/home/tim/.oroshi/node_modules/aberlaas/configs/eslint.js'],
  parserOptions: {
    ecmaVersion: 11,
    sourceType: 'module',
  },
  globals: {
    chalk: false,
    fs: false,
    os: false,
    path: false,
    yaml: false,
  },
  rules: {
    // Don't remove the #!/usr/bin/env zx at the beginning
    'node/shebang': 0,
    // Don't choke on import statements
    'node/no-unsupported-features/es-syntax': 0,
    'node/no-unpublished-import': 0,
  },
};
