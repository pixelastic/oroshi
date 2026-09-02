bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Tuesday. D-7=Sep 15 (Tue), D-1=Sep 21 (Mon), D-0=Sep 22 (Tue)
  EVENT="2026-09-22"
  sourcePrefix="source '${OROSHI_ROOT}/tools/term/zsh/config/functions/autoload/ai/meetup-announce/__lib/compute-schedule.zsh'"
  STATE_FILE="$BATS_TMP_DIR/state.json"

  # Default: all messages pending
  cat > "$STATE_FILE" <<'ENDJSON'
{
  "meetupId": "recTEST",
  "meetupName": "Test Meetup",
  "messages": {
    "early--office-paris--initial": {"state": "pending"},
    "early--office-paris--reminder": {"state": "pending"},
    "early--team-devmarketing--initial": {"state": "pending"},
    "early--help-recruiting--initial": {"state": "pending"},
    "early--topic-relevant--initial": {"state": "pending"},
    "last--office-paris--reminder": {"state": "pending"},
    "last--office-paris--reminder-today": {"state": "pending"},
    "last--team-devmarketing--reminder": {"state": "pending"},
    "last--help-recruiting--reminder": {"state": "pending"}
  }
}
ENDJSON
}

# -- Window detection --

@test "D-10 is early window" {
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-12 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local ids="$(echo "$output" | jq -r '.messages[].id')"
  [[ "$ids" == *"early--"* ]]
  [[ "$ids" != *"last--"* ]]
}

@test "D-1 is last window" {
  # Mark early initial as posted to isolate last-window behavior
  jq '.messages["early--office-paris--initial"].state = "posted"' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-21 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local ids="$(echo "$output" | jq -r '.messages[].id')"
  [[ "$ids" == *"last--"* ]]
}

@test "D-0 is last window" {
  jq '.messages["early--office-paris--initial"].state = "posted"' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-22 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local ids="$(echo "$output" | jq -r '.messages[].id')"
  [[ "$ids" == *"last--"* ]]
}

# -- Early window — first invocation --

@test "generates all 5 early messages when nothing has been posted" {
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-12 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local count="$(echo "$output" | jq '.messages | length')"
  [[ "$count" -eq 5 ]]
  echo "$output" | jq -e '.messages[] | select(.id == "early--office-paris--initial")'
  echo "$output" | jq -e '.messages[] | select(.id == "early--office-paris--reminder")'
  echo "$output" | jq -e '.messages[] | select(.id == "early--team-devmarketing--initial")'
  echo "$output" | jq -e '.messages[] | select(.id == "early--help-recruiting--initial")'
  echo "$output" | jq -e '.messages[] | select(.id == "early--topic-relevant--initial")'
}

@test "early reminder scheduled for D-7" {
  # D-7 = 2026-09-15 (Tue) — no nudge needed
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-12 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local scheduled="$(echo "$output" | jq -r '.messages[] | select(.id == "early--office-paris--reminder") | .scheduledFor')"
  [[ "$scheduled" == 2026-09-15T* ]]
}

@test "early initials scheduled for today" {
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-12 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local dates="$(echo "$output" | jq -r '[.messages[] | select(.id | endswith("--initial")) | .scheduledFor | split("T")[0]] | unique | .[]')"
  [[ "$dates" == "2026-09-12" ]]
}

@test "early messages include channel field" {
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-12 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local channelOfficeParis="$(echo "$output" | jq -r '.messages[] | select(.id == "early--office-paris--initial") | .channel')"
  [[ "$channelOfficeParis" == "#office-paris" ]]
  local channelDevmarketing="$(echo "$output" | jq -r '.messages[] | select(.id == "early--team-devmarketing--initial") | .channel')"
  [[ "$channelDevmarketing" == "#team-devmarketing" ]]
}

@test "topic-relevant is last in order" {
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-12 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local lastId="$(echo "$output" | jq -r '.messages[-1].id')"
  [[ "$lastId" == "early--topic-relevant--initial" ]]
}

# -- Early window — late start --

@test "generates initials but skips reminders when D-7 is past" {
  # today=2026-09-17 (D-5), D-7=Sep 15 is past
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-17 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local count="$(echo "$output" | jq '.messages | length')"
  [[ "$count" -eq 4 ]]
  local ids="$(echo "$output" | jq -r '.messages[].id')"
  [[ "$ids" != *"reminder"* ]]
}

# -- Early window — partial state --

@test "skips messages already posted" {
  jq '.messages["early--office-paris--initial"].state = "posted"' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-12 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local ids="$(echo "$output" | jq -r '.messages[].id')"
  [[ "$ids" != *"early--office-paris--initial"* ]]
  # Reminder still included — initial is posted
  [[ "$ids" == *"early--office-paris--reminder"* ]]
  local count="$(echo "$output" | jq '.messages | length')"
  [[ "$count" -eq 4 ]]
}

@test "skips reminder if its initial was never posted and is not in this batch" {
  # office-paris initial is "drafted" — not pending (not in batch), not posted
  jq '.messages["early--office-paris--initial"].state = "drafted"' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-12 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local ids="$(echo "$output" | jq -r '.messages[].id')"
  [[ "$ids" != *"early--office-paris--initial"* ]]
  [[ "$ids" != *"early--office-paris--reminder"* ]]
}

# -- Last window — D-1 --

@test "D-1 generates last reminder and today messages" {
  # Mark early initial as posted to avoid catch-up
  jq '.messages["early--office-paris--initial"].state = "posted"' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-21 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local count="$(echo "$output" | jq '.messages | length')"
  [[ "$count" -eq 4 ]]
  echo "$output" | jq -e '.messages[] | select(.id == "last--office-paris--reminder")'
  echo "$output" | jq -e '.messages[] | select(.id == "last--office-paris--reminder-today")'
  echo "$output" | jq -e '.messages[] | select(.id == "last--team-devmarketing--reminder")'
  echo "$output" | jq -e '.messages[] | select(.id == "last--help-recruiting--reminder")'
}

@test "last--office-paris--reminder-today scheduled for D-0" {
  jq '.messages["early--office-paris--initial"].state = "posted"' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-21 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local todayScheduled="$(echo "$output" | jq -r '.messages[] | select(.id == "last--office-paris--reminder-today") | .scheduledFor')"
  [[ "$todayScheduled" == 2026-09-22T* ]]
  local reminderScheduled="$(echo "$output" | jq -r '.messages[] | select(.id == "last--office-paris--reminder") | .scheduledFor')"
  [[ "$reminderScheduled" == 2026-09-21T* ]]
}

@test "last--help-recruiting--reminder scheduled for D-1 only" {
  jq '.messages["early--office-paris--initial"].state = "posted"' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
  # D-1: included
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-21 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.messages[] | select(.id == "last--help-recruiting--reminder")'
  local scheduled="$(echo "$output" | jq -r '.messages[] | select(.id == "last--help-recruiting--reminder") | .scheduledFor')"
  [[ "$scheduled" == 2026-09-21T* ]]

  # D-0: not included
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-22 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local absent="$(echo "$output" | jq '[.messages[] | select(.id == "last--help-recruiting--reminder")] | length')"
  [[ "$absent" -eq 0 ]]
}

# -- Last window — D-0 --

@test "D-0 generates only today messages not reminder" {
  jq '.messages["early--office-paris--initial"].state = "posted"' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-22 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local count="$(echo "$output" | jq '.messages | length')"
  [[ "$count" -eq 2 ]]
  echo "$output" | jq -e '.messages[] | select(.id == "last--office-paris--reminder-today")'
  echo "$output" | jq -e '.messages[] | select(.id == "last--team-devmarketing--reminder")'
  local noReminder="$(echo "$output" | jq '[.messages[] | select(.id == "last--office-paris--reminder")] | length')"
  [[ "$noReminder" -eq 0 ]]
}

# -- Last window — catch-up --

@test "includes early--office-paris--initial if never posted (pending)" {
  # All pending — early initial never posted
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-21 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.messages[] | select(.id == "early--office-paris--initial")'
  local count="$(echo "$output" | jq '.messages | length')"
  [[ "$count" -eq 5 ]]
}

@test "includes early--office-paris--initial if drafted but never posted" {
  # Drafted but never posted — catch-up should still include it
  jq '.messages["early--office-paris--initial"].state = "drafted"' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-21 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.messages[] | select(.id == "early--office-paris--initial")'
}

# -- Day-of-week nudging --

@test "D-7 on Monday nudged to Tuesday" {
  # Event=2026-09-14 (Mon), D-7=2026-09-07 (Mon) → Tue 2026-09-08
  bats_run_zsh "$sourcePrefix && compute-schedule 2026-09-14 2026-09-01 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local scheduled="$(echo "$output" | jq -r '.messages[] | select(.id == "early--office-paris--reminder") | .scheduledFor')"
  [[ "$scheduled" == 2026-09-08T* ]]
}

@test "D-7 on Friday nudged to Thursday" {
  # Event=2026-09-18 (Fri), D-7=2026-09-11 (Fri) → Thu 2026-09-10
  bats_run_zsh "$sourcePrefix && compute-schedule 2026-09-18 2026-09-01 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local scheduled="$(echo "$output" | jq -r '.messages[] | select(.id == "early--office-paris--reminder") | .scheduledFor')"
  [[ "$scheduled" == 2026-09-10T* ]]
}

@test "D-7 on Saturday nudged to next Tuesday" {
  # Event=2026-09-19 (Sat), D-7=2026-09-12 (Sat) → Tue 2026-09-15
  bats_run_zsh "$sourcePrefix && compute-schedule 2026-09-19 2026-09-01 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local scheduled="$(echo "$output" | jq -r '.messages[] | select(.id == "early--office-paris--reminder") | .scheduledFor')"
  [[ "$scheduled" == 2026-09-15T* ]]
}

@test "D-7 on Sunday nudged to next Tuesday" {
  # Event=2026-09-20 (Sun), D-7=2026-09-13 (Sun) → Tue 2026-09-15
  bats_run_zsh "$sourcePrefix && compute-schedule 2026-09-20 2026-09-01 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local scheduled="$(echo "$output" | jq -r '.messages[] | select(.id == "early--office-paris--reminder") | .scheduledFor')"
  [[ "$scheduled" == 2026-09-15T* ]]
}

@test "D-7 on Tuesday/Wednesday/Thursday not nudged" {
  # Tue: Event=2026-09-15, D-7=2026-09-08 (Tue)
  bats_run_zsh "$sourcePrefix && compute-schedule 2026-09-15 2026-09-01 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local dateTuesday="$(echo "$output" | jq -r '.messages[] | select(.id == "early--office-paris--reminder") | .scheduledFor')"
  [[ "$dateTuesday" == 2026-09-08T* ]]

  # Wed: Event=2026-09-16, D-7=2026-09-09 (Wed)
  bats_run_zsh "$sourcePrefix && compute-schedule 2026-09-16 2026-09-01 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local dateWednesday="$(echo "$output" | jq -r '.messages[] | select(.id == "early--office-paris--reminder") | .scheduledFor')"
  [[ "$dateWednesday" == 2026-09-09T* ]]

  # Thu: Event=2026-09-17, D-7=2026-09-10 (Thu)
  bats_run_zsh "$sourcePrefix && compute-schedule 2026-09-17 2026-09-01 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local dateThursday="$(echo "$output" | jq -r '.messages[] | select(.id == "early--office-paris--reminder") | .scheduledFor')"
  [[ "$dateThursday" == 2026-09-10T* ]]
}

# -- Time randomization --

@test "early initial time is between 09:47 and 10:28" {
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-12 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local time="$(echo "$output" | jq -r '.messages[] | select(.id == "early--office-paris--initial") | .scheduledFor | split("T")[1]')"
  local hour="${time%%:*}"
  local min="${time##*:}"
  local totalMin=$(( 10#$hour * 60 + 10#$min ))
  [[ $totalMin -ge 587 ]]  # 09:47
  [[ $totalMin -le 628 ]]  # 10:28
}

@test "early reminder time is between 13:47 and 14:28" {
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-12 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  local time="$(echo "$output" | jq -r '.messages[] | select(.id == "early--office-paris--reminder") | .scheduledFor | split("T")[1]')"
  local hour="${time%%:*}"
  local min="${time##*:}"
  local totalMin=$(( 10#$hour * 60 + 10#$min ))
  [[ $totalMin -ge 827 ]]  # 13:47
  [[ $totalMin -le 868 ]]  # 14:28
}

@test "times are not identical across messages in the same batch" {
  bats_run_zsh "$sourcePrefix && compute-schedule $EVENT 2026-09-12 $STATE_FILE"
  [[ "$status" -eq 0 ]]
  # Initials (4 messages in 09:47-10:28 range) should not all share one time
  local uniqueInitialTimes="$(echo "$output" | jq '[.messages[] | select(.id | endswith("--initial")) | .scheduledFor | split("T")[1]] | unique | length')"
  [[ "$uniqueInitialTimes" -ge 2 ]]
}
