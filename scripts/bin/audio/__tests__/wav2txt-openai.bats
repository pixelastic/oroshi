bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Load script functions into mock environment
  echo "source '${OROSHI_ROOT}/scripts/bin/audio/wav2txt-openai'" >>"$BATS_TMP_DIR/mock.zsh"
}

teardown() {
  bats_cleanup
}

# --- Artifact removal ---

@test "removeArtifacts strips known artifact phrase" {
  bats_run_function removeArtifacts "Bonjour. Merci d'avoir regardé cette vidéo !"
  [ "$status" -eq 0 ]
  [ "$output" = "Bonjour. " ]
}

# --- Pass-through ---

@test "removeArtifacts leaves clean text unchanged" {
  bats_run_function removeArtifacts "Bonjour, bienvenue dans cette session."
  [ "$status" -eq 0 ]
  [ "$output" = "Bonjour, bienvenue dans cette session." ]
}
