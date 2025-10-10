import config from 'aberlaas/configs/eslint';

export default [
  ...config,
  {
    rules: {
      // Keep ESLint quotes rule to convert quotes
      quotes: ['error', 'single', { avoidEscape: true }],
      // Configure prettier to not conflict with quotes rule
      'prettier/prettier': [
        'error',
        {
          singleQuote: true,
          // Let ESLint handle quotes, not Prettier
        },
      ],
    },
  },
];
