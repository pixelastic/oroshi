source "${0:h}/fzf-options-base.zsh"
source "${0:h}/fzf-options-prompt-directory.zsh"
source "${0:h}/fzf-colorize-path.zsh"

# Orchestrate raw rg output and transform into FZF candidates
# Globals: SEARCH_DIR, ARGS (from init.zsh)
# Sets: QUERY, EXTRA_RG_ARGS (inherited by pipe subshells)
# Usage: fzf-regexp-source [extra-rg-args...]
fzf-regexp-source() {
  # Setting QUERY, read by other functions
  QUERY="${ARGS[*]}"
  [[ "$QUERY" == "" ]] && return 0

  # Setting EXTRA_RG_ARGS, similarly read by other functions
  EXTRA_RG_ARGS=("$@")

  fzf-regexp-source-raw | fzf-regexp-source-transform
}

# Run ripgrep and output raw results
# Globals: SEARCH_DIR, QUERY, EXTRA_RG_ARGS
fzf-regexp-source-raw() {
  # Fold mode: single shows one match per file, multi shows all
  local foldMode="$(fzf-var-read regexp-fold-mode multi)"
  local -a foldArg=()
  [[ "$foldMode" == "single" ]] && foldArg=(--max-count=1)

  rg \
    --color=always \
    --no-heading \
    --with-filename \
    --line-number \
    --field-match-separator='⦙' \
    --field-context-separator='⦙' \
    "${EXTRA_RG_ARGS[@]}" \
    "${foldArg[@]}" \
    -- "$QUERY" \
    "$SEARCH_DIR" || true
}

# Transform raw ripgrep output (stdin) into FZF-suitable ▮-delimited lines
# Globals: SEARCH_DIR
fzf-regexp-source-transform() {
  local rawOutput="$(cat)"
  [[ "$rawOutput" == "" ]] && return 0

  colors-load-definitions
  setopt local_options extended_glob

  local prevFile=""
  for line in ${(f)rawOutput}; do
    [[ "$line" == "" ]] && continue

    # Strip ANSI codes to parse fields
    local clean="${line//$'\e['[0-9;]#m/}"
    local parts=(${(@s/⦙/)clean})

    # Group separator from ripgrep (--): visual spacer opening file at line 1
    if [[ ${#parts} -eq 1 ]]; then
      echo "${prevFile}▮1▮"
      continue
    fi

    local filepath="${parts[1]}"
    local lineNumber="${parts[2]}"
    local content="${line##*⦙}"

    # Header when finding matches in a new file
    if [[ "$filepath" != "$prevFile" ]]; then
      local relPath="${filepath#"${SEARCH_DIR}"/}"
      fzf-colorize-path "$relPath"
      echo "${filepath}▮1▮${REPLY}"
      prevFile="$filepath"
    fi

    # Adding line number
    colorize --reply "${(l:3:: :)lineNumber}" comment
    local coloredNum="$REPLY"

    echo "${filepath}▮${lineNumber}▮${coloredNum}  ${content}"
  done
}

# Shared fzf-options for regexp scripts
# Globals: SEARCH_DIR, SCRIPT_NAME
fzf-regexp-options() {
  colors-load-definitions

  fzf-options-base
  echo "--disabled"
  echo "--with-nth=3"

  fzf-regexp-fold-prompt
  echo "--prompt=${REPLY}"

  local bindReload="reload(${SCRIPT_NAME} --source {q} || true)"
  local bindToggle="execute-silent(${SCRIPT_NAME} --fold-toggle)"
  local bindPrompt="transform-prompt(${SCRIPT_NAME} --prompt)"

  echo "--bind=change:${bindReload}"
  echo "--bind=f1:${bindToggle}+${bindReload}+${bindPrompt}"

  echo "--color=query:${COLORS[regexp]}:regular"
  echo "--color=info:${COLORS[regexp]}"
  echo "--color=separator:${COLORS[regexp]}"
}

# Shared fzf-postprocess for regexp scripts
fzf-regexp-postprocess() {
  local input="$(cat)"
  [[ "$input" == "" ]] && return 0

  for line in ${(f)input}; do
    [[ "$line" == "" ]] && continue
    local fields=(${(@s/▮/)line})
    print -- "${fields[1]}:${fields[2]}"
  done
}

# Handle --fold-toggle and --prompt, then fall through to fzf-dispatch
fzf-regexp-dispatch() {
  zparseopts -D -E \
    -fold-toggle=flagFoldToggle \
    -prompt=flagPrompt

  local isFoldToggle=${#flagFoldToggle}
  local isPrompt=${#flagPrompt}

  if [[ $isFoldToggle == "1" ]]; then
    fzf-regexp-fold-toggle
    exit 0
  fi
  if [[ $isPrompt == "1" ]]; then
    fzf-regexp-fold-prompt
    echo "$REPLY"
    exit 0
  fi

  fzf-dispatch
}

# Toggle fold mode between multi (all matches) and single (one per file)
fzf-regexp-fold-toggle() {
  local currentMode="$(fzf-var-read regexp-fold-mode multi)"
  if [[ "$currentMode" == "multi" ]]; then
    fzf-var-write regexp-fold-mode single
    return 0
  fi
  fzf-var-write regexp-fold-mode multi
}

# Generate the FZF prompt badge with fold mode indicator
# Globals: SEARCH_DIR
# Result: $REPLY
fzf-regexp-fold-prompt() {
  icons-load-definitions
  colors-load-definitions

  # Pick icon based on mode
  local currentMode="$(fzf-var-read regexp-fold-mode multi)"
  local icon="$ICONS[fzf-fold]"
  [[ "$currentMode" == "single" ]] && icon="$ICONS[fzf-unfold]"

  colorize --reply " ${icon} f1 " $COLORS[white] $COLORS[regexp]
  local badge="$REPLY"
  local dirPrompt="$(fzf-options-prompt-directory "$SEARCH_DIR")"

  REPLY="${badge}${dirPrompt}"
}
