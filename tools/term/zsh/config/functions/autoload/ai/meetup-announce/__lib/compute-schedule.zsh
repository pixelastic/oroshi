# Compute which messages to write this invocation
# Usage:
# $ compute-schedule <eventDate> <today> <stateJsonPath>
# Outputs JSON array of {id, scheduledFor, scheduledAt, channel}

# Guard: skip if already defined (e.g. mocked in tests)
whence compute-schedule >/dev/null && return 0

function compute-schedule() {
  setopt local_options err_return

  local eventDate="$1"
  local today="$2"
  local stateJsonPath="$3"

  local dateMinus1="$(date --date "$eventDate - 1 day" +%Y-%m-%d)"
  local dateMinus7="$(date --date "$eventDate - 7 days" +%Y-%m-%d)"

  # Determine window: early (today < D-1) or last (today >= D-1)
  local window="early"
  [[ ! "$today" < "$dateMinus1" ]] && window="last"

  local result="[]"

  if [[ "$window" == "early" ]]; then
    result="$(__compute_early "$stateJsonPath" "$today" "$dateMinus7" "$eventDate")"
  else
    result="$(__compute_last "$stateJsonPath" "$today" "$dateMinus1" "$eventDate")"
  fi

  echo "$result"
}

function __compute_early() {
  setopt local_options err_return

  local stateJsonPath="$1"
  local today="$2"
  local dateMinus7="$3"
  local eventDate="$4"

  local isDayMinus7Past=0
  [[ "$today" > "$dateMinus7" ]] && isDayMinus7Past=1

  local nudgedDayMinus7="$(__nudge_date "$dateMinus7")"

  # Ordered list of early messages
  local earlyMessages=(
    "early--office-paris--initial"
    "early--office-paris--reminder"
    "early--team-devmarketing--initial"
    "early--help-recruiting--initial"
    "early--topic-relevant--initial"
  )

  # Track which initials are in this batch (pending)
  local -A initialInBatch
  local id
  for id in "${earlyMessages[@]}"; do
    # Skip non-initial messages
    [[ "$id" != *"--initial" ]] && continue
    local state="$(jq -r \
      --arg id "$id" \
      '.messages[$id].state' \
      "$stateJsonPath")"
    [[ "$state" == "pending" ]] && initialInBatch[$id]=1
  done

  local result="[]"

  for id in "${earlyMessages[@]}"; do
    local state="$(jq -r \
      --arg id "$id" \
      '.messages[$id].state' \
      "$stateJsonPath")"

    # Skip already-processed messages
    [[ "$state" != "pending" ]] && continue

    local channel="$(__extract_channel "$id")"

    # Reminder-specific checks
    if [[ "$id" == *"--reminder" ]]; then
      # Skip if D-7 is past
      [[ $isDayMinus7Past -eq 1 ]] && continue

      # Skip if initial was never posted and is not in this batch
      local initialId="${id%--reminder}--initial"
      local initialState="$(jq -r \
        --arg id "$initialId" \
        '.messages[$id].state' \
        "$stateJsonPath")"
      [[ "$initialState" != "posted" && "${initialInBatch[$initialId]:-0}" != "1" ]] && continue

      local scheduledAt="$(__random_time 13 47 14 28)"
      result="$(echo "$result" | jq \
        --arg id "$id" \
        --arg date "$nudgedDayMinus7" \
        --arg time "$scheduledAt" \
        --arg channel "#$channel" \
      '. + [{
          "id": $id,
          "scheduledFor": $date,
          "scheduledAt": $time,
          "channel": $channel
        }]')"
      continue
    fi

    # Initial
    local scheduledAt="$(__random_time 9 47 10 28)"
    result="$(echo "$result" | jq \
      --arg id "$id" \
      --arg time "$scheduledAt" \
      --arg channel "#$channel" \
    '. + [{
        "id": $id,
        "scheduledFor": "now",
        "scheduledAt": $time,
        "channel": $channel
      }]')"
  done

  echo "$result"
}

function __compute_last() {
  setopt local_options err_return

  local stateJsonPath="$1"
  local today="$2"
  local dateMinus1="$3"
  local eventDate="$4"

  local result="[]"

  # Catch-up: include early--office-paris--initial if never posted
  local earlyInitialState="$(jq -r \
    '.messages["early--office-paris--initial"].state' \
    "$stateJsonPath")"
  if [[ "$earlyInitialState" != "posted" ]]; then
    local scheduledAt="$(__random_time 9 47 10 28)"
    result="$(echo "$result" | jq \
      --arg time "$scheduledAt" \
    '. + [{
        "id": "early--office-paris--initial",
        "scheduledFor": "now",
        "scheduledAt": $time,
        "channel": "#office-paris"
      }]')"
  fi

  # last--office-paris--reminder (D-1): only if today == D-1 and pending
  local reminderState="$(jq -r \
    '.messages["last--office-paris--reminder"].state' \
    "$stateJsonPath")"
  if [[ "$today" == "$dateMinus1" && "$reminderState" == "pending" ]]; then
    local scheduledAt="$(__random_time 9 47 10 28)"
    result="$(echo "$result" | jq \
      --arg date "$dateMinus1" \
      --arg time "$scheduledAt" \
    '. + [{
        "id": "last--office-paris--reminder",
        "scheduledFor": $date,
        "scheduledAt": $time,
        "channel": "#office-paris"
      }]')"
  fi

  # last--office-paris--reminder-today (D-0): on D-0 if pending, also drafted on D-1
  local todayState="$(jq -r \
    '.messages["last--office-paris--reminder-today"].state' \
    "$stateJsonPath")"
  local isDayMinus1OrDay0=0
  [[ "$today" == "$eventDate" || "$today" == "$dateMinus1" ]] && isDayMinus1OrDay0=1

  if [[ "$todayState" == "pending" && $isDayMinus1OrDay0 -eq 1 ]]; then
    local scheduledAt="$(__random_time 10 47 11 28)"
    result="$(echo "$result" | jq \
      --arg date "$eventDate" \
      --arg time "$scheduledAt" \
    '. + [{
        "id": "last--office-paris--reminder-today",
        "scheduledFor": $date,
        "scheduledAt": $time,
        "channel": "#office-paris"
      }]')"
  fi

  # last--team-devmarketing--reminder (D-0): same logic as reminder-today
  local devmarketingState="$(jq -r \
    '.messages["last--team-devmarketing--reminder"].state' \
    "$stateJsonPath")"
  if [[ "$devmarketingState" == "pending" && $isDayMinus1OrDay0 -eq 1 ]]; then
    local scheduledAt="$(__random_time 10 47 11 28)"
    result="$(echo "$result" | jq \
      --arg date "$eventDate" \
      --arg time "$scheduledAt" \
    '. + [{
        "id": "last--team-devmarketing--reminder",
        "scheduledFor": $date,
        "scheduledAt": $time,
        "channel": "#team-devmarketing"
      }]')"
  fi

  # last--help-recruiting--reminder (D-1): thread reply, not schedulable
  local helpRecruitingState="$(jq -r \
    '.messages["last--help-recruiting--reminder"].state' \
    "$stateJsonPath")"
  if [[ "$helpRecruitingState" == "pending" && "$today" == "$dateMinus1" ]]; then
    local scheduledAt="$(__random_time 9 47 10 28)"
    result="$(echo "$result" | jq \
      --arg date "$dateMinus1" \
      --arg time "$scheduledAt" \
    '. + [{
        "id": "last--help-recruiting--reminder",
        "scheduledFor": $date,
        "scheduledAt": $time,
        "channel": "#help-recruiting"
      }]')"
  fi

  echo "$result"
}

function __nudge_date() {
  setopt local_options err_return

  local inputDate="$1"
  local dayOfWeek="$(date --date "$inputDate" +%u)"  # 1=Mon, 7=Sun

  # Tue(2), Wed(3), Thu(4) → no nudge
  if [[ $dayOfWeek -ge 2 && $dayOfWeek -le 4 ]]; then
    echo "$inputDate"
    return 0
  fi

  # Mon(1) → Tue (+1)
  if [[ $dayOfWeek -eq 1 ]]; then
    date --date "$inputDate + 1 day" +%Y-%m-%d
    return 0
  fi

  # Fri(5) → Thu (-1)
  if [[ $dayOfWeek -eq 5 ]]; then
    date --date "$inputDate - 1 day" +%Y-%m-%d
    return 0
  fi

  # Sat(6) → next Tue (+3)
  if [[ $dayOfWeek -eq 6 ]]; then
    date --date "$inputDate + 3 days" +%Y-%m-%d
    return 0
  fi

  # Sun(7) → next Tue (+2)
  date --date "$inputDate + 2 days" +%Y-%m-%d
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
