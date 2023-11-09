#!/usr/bin/env zx
// Converts a .json file to json5 format
// json5 is json flavored for better consumption by humans
// https://github.com/json5/json5
//
// Usage:
// $ json2json5 ./path/to/file.json        # Output JSON5 version
// $ cat ./path/to/file.json | json2json5  # Output JSON5 version

import JSON5 from 'json5';
import firost from 'firost';

const Json2Json5 = {
  hasStdin() {
    return !process.stdin.isTTY;
  },
  hasArgument() {
    return argv._.length > 0;
  },
  async getRawInput() {
    // Input is piped
    if (this.hasStdin()) {
      return await stdin();
    }

    // File is passed as argument
    if (this.hasArgument()) {
      return firost.read(argv._[0]);
    }

    // No input
    console.info('You need to provide either a filepath or stdin input');
    process.exit(1);
  },
  async run() {
    const rawInput = await this.getRawInput();
    const input = JSON.parse(rawInput);
    console.info(JSON5.stringify(input, { space: 2 }));
  },
};

(async () => {
  await Json2Json5.run();
})();
