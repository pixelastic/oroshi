import config from 'aberlaas/configs/eslint';

export default [
  ...config,
  {
    name: 'oroshi/scripts-bin',
    files: ['scripts/bin/**'],
    rules: { 'n/hashbang': 'off' },
  },
  {
    name: 'oroshi/gnome-extension',
    files: ['tools/ubuntu/24.04/extensions/*/lib/**'],
    rules: {
      'import/no-unresolved': 'off',
      'aberlaas/prefer-lodash-methods': 'off',
      'aberlaas/prefer-lodash-chain': 'off',
      'aberlaas/prefer-lodash-is-empty': 'off',
    },
  },
];
