# Compute which messages to write this invocation
# Usage:
# $ compute-schedule <eventDate> <today> <stateJsonPath>
# Outputs JSON object: {window, messages: [{id, scheduledFor, channel, state}]}

# Guard: skip if already defined (e.g. mocked in tests)
whence compute-schedule >/dev/null && return 0

source "${0:A:h}/config.zsh"

function compute-schedule() {
  setopt local_options err_return

  local eventDate="$1"
  local today="$2"
  local stateJsonPath="$3"

  local windowStart="$(__business_days_before_2 "$eventDate")"

  # Determine window: early (today < windowStart) or last (today >= windowStart)
  # windowStart = 2 business days before the event (weekends excluded)
  local window="early"
  [[ ! "$today" < "$windowStart" ]] && window="last"

  local result="[]"

  if [[ "$window" == "early" ]]; then
    result="$(__compute_early "$stateJsonPath" "$today" "$eventDate")"
  else
    result="$(__compute_last "$stateJsonPath" "$today" "$eventDate")"
  fi

  jo window="$window" messages="$result"
}

function __compute_early() {
  setopt local_options err_return

  local stateJsonPath="$1"
  local today="$2"
  local eventDate="$3"

  local scheduledDayMinus7="$(__schedule_date "$eventDate" 7 "$today")"

  # Track which initials are in this batch (pending or drafted)
  local -A initialInBatch
  local id
  for id in "${earlyMessages[@]}"; do
    # Skip non-initial messages
    [[ "$id" != *"--initial" ]] && continue
    local state="$(jq -r \
      --arg id "$id" \
      '.messages[$id].state' \
      "$stateJsonPath")"
    [[ "$state" == "pending" || "$state" == "drafted" ]] && initialInBatch[$id]=1
  done

  local result="[]"

  for id in "${earlyMessages[@]}"; do
    local state="$(jq -r \
      --arg id "$id" \
      '.messages[$id].state' \
      "$stateJsonPath")"

    # Skip already-posted messages
    [[ "$state" == "posted" ]] && continue

    local channel="$(__extract_channel "$id")"

    # Reminder-specific checks
    if [[ "$id" == *"--reminder" ]]; then
      # Skip if D-7 is past or falls on weekend (empty = filtered out)
      [[ "$scheduledDayMinus7" == "" ]] && continue

      # Skip if initial was never posted and is not in this batch
      local initialId="${id%--reminder}--initial"
      local initialState="$(jq -r \
        --arg id "$initialId" \
        '.messages[$id].state' \
        "$stateJsonPath")"
      [[ "$initialState" != "posted" && "${initialInBatch[$initialId]:-0}" != "1" ]] && continue

      # After-lunch slot (13:47–14:28): non-round bounds + randomization make
      # scheduled posts look human-posted rather than automated
      local scheduledAt="$(__random_time 13 47 14 28)"
      result="$(echo "$result" | jq \
        --arg id "$id" \
        --arg scheduled "${scheduledDayMinus7}T${scheduledAt}" \
        --arg channel "#$channel" \
        --arg state "$state" \
      '. + [{
          "id": $id,
          "scheduledFor": $scheduled,
          "channel": $channel,
          "state": $state
        }]')"
      continue
    fi

    # Initial — no scheduledFor, posted immediately
    result="$(echo "$result" | jq \
      --arg id "$id" \
      --arg channel "#$channel" \
      --arg state "$state" \
    '. + [{
        "id": $id,
        "channel": $channel,
        "state": $state
      }]')"
  done

  echo "$result"
}

function __compute_last() {
  setopt local_options err_return

  local stateJsonPath="$1"
  local today="$2"
  local eventDate="$3"

  # Scheduling metadata per message: "offset startH startM endH endM"
  # D-1 → early-morning slot (9:47–10:28), D-0 → late-morning slot (10:47–11:28)
  # Non-round bounds + randomization make scheduled posts look human-posted
  local -A lastSchedule
  lastSchedule[last--office-paris--reminder]="1 9 47 10 28"
  lastSchedule[last--office-paris--reminder-today]="0 10 47 11 28"
  lastSchedule[last--team-devmarketing--reminder]="0 10 47 11 28"
  lastSchedule[last--help-recruiting--reminder]="1 9 47 10 28"

  local result="[]"

  # Catch-up: include early--office-paris--initial if never posted
  local earlyInitialState="$(jq -r \
    '.messages["early--office-paris--initial"].state' \
    "$stateJsonPath")"
  if [[ "$earlyInitialState" != "posted" ]]; then
    result="$(echo "$result" | jq \
      --arg state "$earlyInitialState" \
    '. + [{
        "id": "early--office-paris--initial",
        "channel": "#office-paris",
        "state": $state
      }]')"
  fi

  local id
  for id in "${lastMessages[@]}"; do
    local meta=(${=lastSchedule[$id]})
    local offset=$meta[1]
    local scheduledDay="$(__schedule_date "$eventDate" "$offset" "$today")"

    local state="$(jq -r \
      --arg id "$id" \
      '.messages[$id].state' \
      "$stateJsonPath")"

    # Skip past schedule dates (empty = filtered out) and already-posted
    [[ "$scheduledDay" == "" ]] && continue
    [[ "$state" == "posted" ]] && continue

    local scheduledAt="$(__random_time $meta[2] $meta[3] $meta[4] $meta[5])"
    local channel="$(__extract_channel "$id")"

    result="$(echo "$result" | jq \
      --arg id "$id" \
      --arg scheduled "${scheduledDay}T${scheduledAt}" \
      --arg channel "#$channel" \
      --arg state "$state" \
    '. + [{
        "id": $id,
        "scheduledFor": $scheduled,
        "channel": $channel,
        "state": $state
      }]')"
  done

  echo "$result"
}

function __business_days_before_2() {
  setopt local_options err_return

  local eventDate="$1"
  local dow="$(date --date "$eventDate" +%u)"

  # Mon(1)/Tue(2): subtract 4 calendar days to skip the weekend
  # Wed–Fri: subtract 2 calendar days
  local offset=2
  if [[ $dow -le 2 ]]; then
    offset=4
  fi

  date --date "$eventDate - $offset days" +%Y-%m-%d
}

# Compute a workday-safe scheduled date
# Usage: __schedule_date <referenceDate> <daysOffset> [todayOverride]
# Returns the date, or empty string if past
function __schedule_date() {
  setopt local_options err_return

  local referenceDate="$1"
  local daysOffset="$2"
  local today="${3:-$(date +%Y-%m-%d)}"

  local computed="$(date --date "$referenceDate - $daysOffset days" +%Y-%m-%d)"
  local dayOfWeek="$(date --date "$computed" +%u)"

  # Sat(6) → previous Friday (-1)
  [[ $dayOfWeek -eq 6 ]] && computed="$(date --date "$computed - 1 day" +%Y-%m-%d)"

  # Sun(7) → previous Friday (-2)
  [[ $dayOfWeek -eq 7 ]] && computed="$(date --date "$computed - 2 days" +%Y-%m-%d)"

  # Past dates return empty
  [[ "$computed" < "$today" ]] && return 0

  echo "$computed"
}

function __extract_channel() {
  setopt local_options err_return

  local id="$1"
  # ID format: <window>--<channel>--<type>
  local withoutWindow="${id#*--}"
  local channel="${withoutWindow%--*}"
  echo "$channel"
}

function __random_time() {
  setopt local_options err_return

  local startHour="$1"
  local startMinutes="$2"
  local endHour="$3"
  local endMinutes="$4"

  local startTotal=$(( startHour * 60 + startMinutes ))
  local endTotal=$(( endHour * 60 + endMinutes ))

  local randomTotal="$(shuf \
    --input-range "${startTotal}-${endTotal}" \
    --head-count 1)"
  local hour=$(( randomTotal / 60 ))
  local minutes=$(( randomTotal % 60 ))

  printf "%02d:%02d" "$hour" "$minutes"
}
