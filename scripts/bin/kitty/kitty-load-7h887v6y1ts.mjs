#!/usr/bin/env zx
// # Load a saved session from a previous save

void async function() {
  const tmpDir=path.resolve(os.homedir(), 'local/tmp/kitty')
  const input = require(path.resolve(tmpDir, 'save.json'))
  console.log(data)
}()


// mkdir -p ~/local/tmp/kitty
// cd ~/local/tmp/kitty

// # We first need to convert the JSON into a session file.
// # We do that on load and not on save to be able to fix the script if needed, and
// # keep the save as fast as possible

// local output=()

// kkk

// jq -c '. | map([.tabs]) | map([.id, .title]) ' ./save.json
