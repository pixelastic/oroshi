function git-env-start() {
  gitstatus_check 'MY' && return
  echo "Start it"
  gitstatus_start 'MY'
  # -s -1 -u -1 -c -1 -d -1 'MY'
}
