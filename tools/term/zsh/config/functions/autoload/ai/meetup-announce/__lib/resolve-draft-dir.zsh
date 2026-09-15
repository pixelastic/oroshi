# Create or reuse a draft directory keyed by Airtable record ID
# Usage:
# $ resolve-draft-dir <recordId> <meetupName>

# Guard: skip if already defined (e.g. mocked in tests)
whence resolve-draft-dir >/dev/null && return 0

source "${0:A:h}/config.zsh"

function resolve-draft-dir() {
  setopt local_options err_return

  local recordId="$1"
  local meetupName="$2"

  local draftRoot="$OROSHI_TMP_FOLDER/claude/meetup-announce"
  local draftDir="$draftRoot/$recordId"
  local stateFile="$draftDir/state.json"

  # Existing draft directory — update meetupName and return
  if [[ -d "$draftDir" ]]; then
    local updated="$(jq --arg name "$meetupName" '.meetupName = $name' "$stateFile")"
    echo "$updated" > "$stateFile"
    echo "$draftDir"
    return 0
  fi

  # New draft directory — create folder structure + state.json
  mkdir -p "$draftDir"

  local messageIds=("${earlyMessages[@]}" "${lastMessages[@]}")

  local messagesJson="{}"
  local id
  for id in "${messageIds[@]}"; do
    messagesJson="$(echo "$messagesJson" | jq --arg id "$id" '. + {($id): {"state": "pending"}}')"
  done

  jq -n \
    --arg meetupId "$recordId" \
    --arg meetupName "$meetupName" \
    --argjson messages "$messagesJson" \
    '{meetupId: $meetupId, meetupName: $meetupName, messages: $messages}' \
    > "$stateFile"

  echo "$draftDir"
}
