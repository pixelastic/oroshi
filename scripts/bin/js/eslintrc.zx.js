module.exports = {
  extends: ['/home/tim/.oroshi/node_modules/aberlaas/configs/eslint.js'],
  parserOptions: {
    ecmaVersion: 11,
    sourceType: 'module',
  },
  // Define all the API reference
  // https://google.github.io/zx/api
  globals: {
    $: false,
    cd: false,
    fetch: false,
    question: false,
    sleep: false,
    echo: false,
    stdin: false,
    within: false,
    retry: false,
    spinner: false,
    glob: false,
    which: false,
    argv: false,
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
    'node/no-extraneous-import': 0,
    // Allow simply defining the exit codes
    'no-process-exit': 0,
  },
};
