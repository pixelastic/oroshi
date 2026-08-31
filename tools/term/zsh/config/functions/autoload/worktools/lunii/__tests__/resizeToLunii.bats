bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# Source the lib function inside bats_run_zsh
_source_lib() {
  local libDir="tools/term/zsh/config/functions/autoload/worktools/lunii/__lib"
  echo "source $libDir/resizeToLunii.zsh"
}

@test "calls magick with fit+pad arguments for 320x240" {
  magick() { echo "$@" >> "$BATS_TMP_DIR/magick_calls.txt"; }
  bats_mock magick

  touch "$BATS_TMP_DIR/cover.png"
  bats_run_zsh "$(_source_lib) && resizeToLunii $BATS_TMP_DIR/cover.png"
  [[ "$status" -eq 0 ]]

  [[ -f "$BATS_TMP_DIR/magick_calls.txt" ]]
  local calls="$(cat "$BATS_TMP_DIR/magick_calls.txt")"
  [[ "$calls" == *"-resize 320x240"* ]]
  [[ "$calls" == *"-background black"* ]]
  [[ "$calls" == *"-gravity center"* ]]
  [[ "$calls" == *"-extent 320x240"* ]]
}

@test "converts JPEG input to PNG output" {
  magick() { echo "$@" >> "$BATS_TMP_DIR/magick_calls.txt"; }
  bats_mock magick

  touch "$BATS_TMP_DIR/cover.jpeg"
  bats_run_zsh "$(_source_lib) && resizeToLunii $BATS_TMP_DIR/cover.jpeg"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/magick_calls.txt")"
  # Input is the JPEG file
  [[ "$calls" == *"$BATS_TMP_DIR/cover.jpeg"* ]]
  # Output is PNG
  [[ "$calls" == *"$BATS_TMP_DIR/cover.png"* ]]
}

@test "keeps PNG input as PNG output" {
  magick() { echo "$@" >> "$BATS_TMP_DIR/magick_calls.txt"; }
  bats_mock magick

  touch "$BATS_TMP_DIR/cover.png"
  bats_run_zsh "$(_source_lib) && resizeToLunii $BATS_TMP_DIR/cover.png"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/magick_calls.txt")"
  # Both input and output should be the same .png path
  [[ "$calls" == *"$BATS_TMP_DIR/cover.png"* ]]
  [[ "$calls" != *".jpeg"* ]]
  [[ "$calls" != *".jpg"* ]]
}
