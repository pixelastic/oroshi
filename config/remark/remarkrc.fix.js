/* eslint-disable import/no-commonjs */
const os = require('os');
module.exports = {
  plugins: [
    `${os.homedir()}/.oroshi/node_modules/remark-frontmatter`,
    `${os.homedir()}/.oroshi/node_modules/remark-reference-links`,
  ],
};
