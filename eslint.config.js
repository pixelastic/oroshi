import config from 'aberlaas/configs/eslint';

export default [
  ...config,
  {
    name: 'oroshi/scripts-bin',
    files: ['scripts/bin/**'],
    rules: { 'n/hashbang': 'off' },
  },
];
