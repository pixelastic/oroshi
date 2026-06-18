bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${OROSHI_ROOT}/scripts/bin/audio/wav2txt-openai'"
}

# --- Artifact removal ---

@test "removeArtifacts strips known artifact phrase" {
  bats_run_zsh "${sourcePrefix}; removeArtifacts 'Bonjour. Merci d'\''avoir regardé cette vidéo !'"
  [ "$status" -eq 0 ]
  [ "$output" = "Bonjour. " ]
}

# --- Pass-through ---

@test "removeArtifacts leaves clean text unchanged" {
  bats_run_zsh "${sourcePrefix}; removeArtifacts 'Bonjour, bienvenue dans cette session.'"
  [ "$status" -eq 0 ]
  [ "$output" = "Bonjour, bienvenue dans cette session." ]
}
