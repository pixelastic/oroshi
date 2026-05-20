load '../../../config/term/bats/helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
}

# --- Single file ---

@test "deletes a single file" {
  touch "$TMP_DIRECTORY/foo.txt"
  run better-rm "$TMP_DIRECTORY/foo.txt"
  [ "$status" -eq 0 ]
  [ ! -e "$TMP_DIRECTORY/foo.txt" ]
}

# --- Glob ---

@test "deletes multiple files via glob" {
  touch "$TMP_DIRECTORY/a.txt" "$TMP_DIRECTORY/b.txt" "$TMP_DIRECTORY/c.txt"
  run better-rm "$TMP_DIRECTORY"/a.txt "$TMP_DIRECTORY"/b.txt "$TMP_DIRECTORY"/c.txt
  [ "$status" -eq 0 ]
  [ ! -e "$TMP_DIRECTORY/a.txt" ]
  [ ! -e "$TMP_DIRECTORY/b.txt" ]
  [ ! -e "$TMP_DIRECTORY/c.txt" ]
}

# --- Flag compatibility ---

@test "ignores -f flag" {
  touch "$TMP_DIRECTORY/foo.txt"
  run better-rm -f "$TMP_DIRECTORY/foo.txt"
  [ "$status" -eq 0 ]
  [ ! -e "$TMP_DIRECTORY/foo.txt" ]
}

@test "ignores -r flag" {
  touch "$TMP_DIRECTORY/foo.txt"
  run better-rm -r "$TMP_DIRECTORY/foo.txt"
  [ "$status" -eq 0 ]
  [ ! -e "$TMP_DIRECTORY/foo.txt" ]
}

@test "ignores -rf combined flag" {
  touch "$TMP_DIRECTORY/foo.txt"
  run better-rm -rf "$TMP_DIRECTORY/foo.txt"
  [ "$status" -eq 0 ]
  [ ! -e "$TMP_DIRECTORY/foo.txt" ]
}
