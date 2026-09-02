# Fetch a single meetup record from Airtable
# Usage:
# $ fetch-meetup <recordId>

# Guard: skip if already defined (e.g. mocked in tests)
whence fetch-meetup >/dev/null && return 0

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
    guestRegisteredCount
    guestAttendingCountFinal
    pictureMain
    pictureLogo
    pictureBackground
    horizontalScreen
    verticalScreen
    signagePrint
  )
  local fieldList="${(j/,/)fields}"

  AIRTABLE_TOKEN="$AIRTABLE_DEVREL_MEETUPS_TOKEN_READONLY" \
    airtable-record-read \
    --base appOxzXtlKI4Q7qr4 \
    --table Meetups \
    --record "$recordId" \
    --fields "$fieldList"
}
