/* eslint-disable import/no-commonjs */
const os = require('os');
/**
 * Linting config.
 * Check the following links for the list of all rules:
 * - https://github.com/remarkjs/remark-lint/tree/master/packages/remark-preset-lint-consistent
 * - https://github.com/remarkjs/remark-lint/tree/master/packages/remark-preset-lint-recommended
 * - https://github.com/remarkjs/remark-lint/tree/master/packages/remark-preset-lint-markdown-style-guide
 **/
module.exports = {
  plugins: [
    `${os.homedir()}/.oroshi/node_modules/remark-frontmatter`,
    `${os.homedir()}/.oroshi/node_modules/remark-preset-lint-consistent`,
    `${os.homedir()}/.oroshi/node_modules/remark-preset-lint-recommended`,
    `${os.homedir()}/.oroshi/node_modules/remark-preset-lint-markdown-style-guide`,

    // Following rules are configured to fit what prettier does
    `lint-no-trailing-spaces`, // No trailing spaces
    [`lint-emphasis-marker`, '_'], // Italic with _, bold with **
    [`lint-list-item-spacing`, false], // No need to add lines between list items
    [`lint-list-item-indent`, 'space'], // Indent list items with one space
    [`lint-maximum-heading-length`, 80], // Warn on heading that can be too long
    [`lint-maximum-line-length`, 80], // Warn on lines that are too long
  ],
};
