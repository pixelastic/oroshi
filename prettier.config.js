import config from 'aberlaas/configs/prettier';

export default {
  ...config,
  plugins: [...config.plugins, '@prettier/plugin-xml'],
};
