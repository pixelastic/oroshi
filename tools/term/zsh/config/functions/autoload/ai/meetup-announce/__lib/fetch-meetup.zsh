# Fetch a single meetup record from Airtable
# Usage:
# $ fetch-meetup <recordId>

# Guard: skip if already defined (e.g. mocked in tests)
whence fetch-meetup >/dev/null && return 0

source "${0:A:h}/config.zsh"

function fetch-meetup() {
  setopt local_options err_return

  local recordId="$1"

  local fields=(
    UUID
    name
    date
    startTime
    endTime
    description
    URL
    notes
    helpersFullName
    speakersFullName
    guestRegisteredCount
    guestAttendingCountFinal
  )
  local fieldList="${(j/,/)fields}"

  AIRTABLE_TOKEN="$AIRTABLE_DEVREL_MEETUPS_TOKEN_READONLY" \
    airtable-record-read \
    --base "$AIRTABLE_BASE_ID" \
    --table Meetups \
    --record "$recordId" \
    --fields "$fieldList"
}
