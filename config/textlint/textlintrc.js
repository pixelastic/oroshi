/* eslint-disable import/no-commonjs */
const os = require('os');
module.exports = {
  rules: {
    alex: {
      allow: [
        'actors-actresses',
        'actor-actress',
        'attack',
        'bigger',
        'black',
        'color',
        'color',
        'crash',
        'desire',
        'executed',
        'execution',
        'fear',
        'firing',
        'harder',
        'hooks',
        'hook',
        'host-hostess',
        'itch',
        'killed',
        'kill',
        'middleman-middlewoman',
        'nuts',
        'oral',
        'pros',
        'shooting',
      ],
    },
    'common-misspellings': true,
    editorconfig: true,
    'en-capitalization': true,
    'stop-words': {
      exclude: [
        'relative to', // We need to talk about links "relative to the root",
        'pick out', // Needed word, not to clumsy
        'encounter', // Needed word, not to clumsy
      ],
    },
    terminology: {
      defaultTerms: false,
      terms: `${os.homedir()}/.oroshi/config/textlint/terms.json`,
    },
    'write-good': {
      passive: false,
    },
  },
};
