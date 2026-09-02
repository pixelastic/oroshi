# Synchronously populate prompt parts that are quick to generate
function oroshi-prompt-synchronous-populate() {
  for promptPart in $OROSHI_SYNCHRONOUS_PROMPT_PARTS; do
    eval "oroshi-prompt-populate:${promptPart}"
  done
}

# Asynchronously populate prompt parts that are slow to generate
function oroshi-prompt-asynchronous-populate() {
  # Don't start another background generation if one is already occuring
  if [[ "${OROSHI_ASYNCHRONOUS_PID}" != "0" ]]; then
    return
  fi
  # # Kill the previous prompt generation process if it was already running
  # # This allows keeping only one generation at a time
  # if [[ "${OROSHI_ASYNCHRONOUS_PID}" != "0" ]]; then
  #   kill -s HUP $OROSHI_ASYNCHRONOUS_PID >/dev/null 2>&1 || :
  # fi

  function async() {
    # Save all new parts in a file
    for promptPart in $OROSHI_ASYNCHRONOUS_PROMPT_PARTS; do
      eval "oroshi-prompt-populate:${promptPart}"
      echo $OROSHI_PROMPT_PARTS[$promptPart] > ${OROSHI_ASYNCHRONOUS_SAVE_PATH}/${promptPart}
    done

    prompt-redraw $OROSHI_ZSH_PID
  }

  async &
  disown
  OROSHI_ASYNCHRONOUS_PID=$!
}
