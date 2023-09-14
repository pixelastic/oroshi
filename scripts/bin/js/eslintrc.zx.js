module.exports = {
  extends: ['/home/tim/.oroshi/node_modules/aberlaas/configs/eslint.js'],
  globals: {
    chalk: false,
    fs: false,
    os: false,
    path: false,
    yaml: false,
  },
  rules: {
    'node/shebang': 0,
  },
};
