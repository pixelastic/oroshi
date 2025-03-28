/* eslint-disable import/no-commonjs */
const os = require('os');
const home = os.homedir();

module.exports = {
  plugins: [
    `${home}/.oroshi/node_modules/remark-frontmatter/index.js`,
    `${home}/.oroshi/node_modules/remark-reference-links/index.js`,
  ],
};
