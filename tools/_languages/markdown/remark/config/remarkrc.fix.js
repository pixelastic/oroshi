// eslint-disable-next-line no-undef
const os = require('node:os');

const home = os.homedir();

// eslint-disable-next-line no-undef
module.exports = {
  plugins: [
    `${home}/.oroshi/node_modules/remark-frontmatter/index.js`,
    `${home}/.oroshi/node_modules/remark-reference-links/index.js`,
  ],
};
