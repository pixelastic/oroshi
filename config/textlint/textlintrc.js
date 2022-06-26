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
        'bullshit', // "Developers have a bullshit detector"
        'colors',
        'color',
        'crash',
        'desire',
        'executed',
        'execution',
        'kills', // "Run this command to kill all the processes"
        'poverty', // "End world poverty"
        'dirty', // "Don't use dirty tactics"
        'failed',
        'failures', // "We all learn from our failures"
        'failure',  // "Failure is a learning experience"
        'fear',
        'firing',
        'he-she', // We should be able to use the right pronoun
        'her-him',
        'harder',
        'hooks',
        'hook',
        'host-hostess',
        'itch',
        'killed',
        'kill',
        'middleman-middlewoman',
        'refugees', // "Konexio helps refugees"
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
        'Saas', // Software as a Service is fine
        'relative to', // We need to talk about links "relative to the root",
        'pick out', // Needed word, not to clumsy
        'encounter', // Needed word, not to clumsy
        'outside the box', // This is a required quality for DevRel
        'think outside the box',
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
