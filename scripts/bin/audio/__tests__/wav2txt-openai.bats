bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${OROSHI_ROOT}/scripts/bin/audio/wav2txt-openai'"
}
