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
    files: ['tools/ubuntu/24.04/extensions/oroshi-modes/lib/**'],
    rules: { 'import/no-unresolved': 'off' },
  },
];
