bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock audio-duration: 30 seconds
  audio-duration() { echo "30.000000"; }
  # Mock ffmpeg: silence detection returns markers, split calls create files
  ffmpeg() {
    if [[ "$*" == *"silencedetect"* ]]; then
      echo "[silencedetect @ 0x0] silence_start: 5.0"
      echo "[silencedetect @ 0x0] silence_start: 10.0"
      echo "[silencedetect @ 0x0] silence_start: 15.0"
      echo "[silencedetect @ 0x0] silence_start: 20.0"
      echo "[silencedetect @ 0x0] silence_start: 25.0"
      return 0
    fi
    local prev=""
    for arg in "$@"; do
      if [[ "$arg" == "-y" ]]; then
        touch "$prev"
        return 0
      fi
      prev="$arg"
    done
  }
  bats_mock audio-duration ffmpeg

  bats_disable_worktree_aware
}

# --- Legacy mode ---

@test "splits a file into exactly 2 parts" {
  touch "$BATS_TMP_DIR/input.wav"
  bats_run_zsh "cd $BATS_TMP_DIR && audio-split input.wav"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/input-part1.wav" ]]
  [[ -f "$BATS_TMP_DIR/input-part2.wav" ]]
}

@test "legacy mode does not list files on stdout" {
  touch "$BATS_TMP_DIR/input.wav"
  bats_run_zsh "cd $BATS_TMP_DIR && audio-split input.wav"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"part1"* ]]
  [[ "$output" != *"part2"* ]]
}

# --- Max-size mode ---

@test "splits a 50MB file with --max-size 25M into at least 2 parts" {
  truncate --size 50M "$BATS_TMP_DIR/input.wav"
  bats_run_zsh "cd $BATS_TMP_DIR && audio-split --max-size 25M input.wav"
  [[ "$status" -eq 0 ]]
  local count
  count=$(find "$BATS_TMP_DIR" -maxdepth 1 -name 'input-part*.wav' | wc -l)
  [[ "$count" -ge 2 ]]
}

@test "splits a 75MB file with --max-size 25M into at least 3 parts" {
  truncate --size 75M "$BATS_TMP_DIR/input.wav"
  bats_run_zsh "cd $BATS_TMP_DIR && audio-split --max-size 25M input.wav"
  [[ "$status" -eq 0 ]]
  local count
  count=$(find "$BATS_TMP_DIR" -maxdepth 1 -name 'input-part*.wav' | wc -l)
  [[ "$count" -ge 3 ]]
}

@test "lists created files on stdout in max-size mode" {
  truncate --size 50M "$BATS_TMP_DIR/input.wav"
  bats_run_zsh "cd $BATS_TMP_DIR && audio-split --max-size 25M input.wav"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"input-part1.wav"* ]]
  [[ "$output" == *"input-part2.wav"* ]]
}

@test "file smaller than max-size produces a single part" {
  truncate --size 10M "$BATS_TMP_DIR/input.wav"
  bats_run_zsh "cd $BATS_TMP_DIR && audio-split --max-size 25M input.wav"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/input-part1.wav" ]]
  local count
  count=$(find "$BATS_TMP_DIR" -maxdepth 1 -name 'input-part*.wav' | wc -l)
  [[ "$count" -eq 1 ]]
  [[ "$output" == *"input-part1.wav"* ]]
}

# --- Edge cases ---

@test "missing input file returns error" {
  bats_run_zsh "audio-split nonexistent.wav"
  [[ "$status" -ne 0 ]]
}

@test "--max-size with invalid size format returns error" {
  touch "$BATS_TMP_DIR/input.wav"
  bats_run_zsh "cd $BATS_TMP_DIR && audio-split --max-size invalid input.wav"
  [[ "$status" -ne 0 ]]
}
