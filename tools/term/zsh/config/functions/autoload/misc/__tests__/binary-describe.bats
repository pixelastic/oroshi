bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# whatis available

@test "returns whatis description when available" {
  whatis() {
    echo "cat (1)              - concatenate files and print on the standard output"
  }
  bats_mock whatis

  bats_run_zsh "binary-describe cat"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"concatenate"* ]]
}

# whatis unavailable, man available

@test "falls back to man NAME section" {
  whatis() { return 1; }
  man() {
    cat <<'EOF'
NAME
       foobar - a tool for doing things

SYNOPSIS
       foobar [options]
EOF
  }
  col() { cat; }
  bats_mock whatis man col

  bats_run_zsh "binary-describe foobar"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"a tool for doing things"* ]]
}

# whatis and man unavailable, dpkg available

@test "falls back to apt-cache description" {
  whatis() { return 1; }
  man() { return 1; }
  dpkg() { echo "webp: /usr/bin/anim_diff"; }
  apt-cache() { echo "Description-en: Lossy compression of digital photographic images"; }
  bats_mock whatis man dpkg apt-cache

  bats_run_zsh "binary-describe anim_diff"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"Lossy compression"* ]]
}

# nothing available

@test "exits 0 with no output when nothing found" {
  whatis() { return 1; }
  man() { return 1; }
  dpkg() { return 1; }
  bats_mock whatis man dpkg

  bats_run_zsh "binary-describe nonexistent-xyz"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
