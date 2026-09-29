import { fileURLToPath } from 'node:url';
import config from 'aberlaas/configs/prettier';

// Load plugins through their absolute path, so they work from any directory
const xmlPlugin = fileURLToPath(import.meta.resolve('@prettier/plugin-xml'));

export default {
  ...config,
  plugins: [...config.plugins, xmlPlugin],
};
