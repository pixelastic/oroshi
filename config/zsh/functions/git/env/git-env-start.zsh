function git-env-start() {
  gitstatus_check 'OROSHI' && return
  gitstatus_start 'OROSHI'
}
