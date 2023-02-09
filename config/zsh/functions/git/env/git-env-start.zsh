function git-env-start() {
  gitstatus_check 'MY' && return
  gitstatus_start 'MY'
}
