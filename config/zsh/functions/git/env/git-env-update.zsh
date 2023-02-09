function git-env-update() {
  gitstatus_query 'MY'

  # Are we in a git directory?
  export GIT_DIRECTORY_IS_REPOSITORY="0"
  [[ $VCS_STATUS_RESULT == "ok-sync" ]] && GIT_DIRECTORY_IS_REPOSITORY="1"

  # Do we have stashes?
  export GIT_STASH_EXISTS=$VCS_STATUS_STASHES



  # Get all available vars with typeset -m 'VCS_STATUS_*'

# VCS_STATUS_ACTION=''
# VCS_STATUS_COMMITS_AHEAD=3
# VCS_STATUS_COMMITS_BEHIND=0
# VCS_STATUS_COMMIT=ac6d5ee7a61ff343d9f903c8a0a668be20707f9a
# VCS_STATUS_COMMIT_ENCODING=''
# VCS_STATUS_COMMIT_SUMMARY='Don'\''t search in .git folders'
# VCS_STATUS_HAS_CONFLICTED=0
# VCS_STATUS_HAS_STAGED=0
# VCS_STATUS_HAS_UNSTAGED=1
# VCS_STATUS_HAS_UNTRACKED=1
# VCS_STATUS_INDEX_SIZE=1241
# VCS_STATUS_LOCAL_BRANCH=master
# VCS_STATUS_NUM_ASSUME_UNCHANGED=0
# VCS_STATUS_NUM_CONFLICTED=0
# VCS_STATUS_NUM_SKIP_WORKTREE=0
# VCS_STATUS_NUM_STAGED=0
# VCS_STATUS_NUM_STAGED_DELETED=0
# VCS_STATUS_NUM_STAGED_NEW=0
# VCS_STATUS_NUM_UNSTAGED=1
# VCS_STATUS_NUM_UNSTAGED_DELETED=0
# VCS_STATUS_NUM_UNTRACKED=1
# VCS_STATUS_PUSH_COMMITS_AHEAD=0
# VCS_STATUS_PUSH_COMMITS_BEHIND=0
# VCS_STATUS_PUSH_REMOTE_NAME=''
# VCS_STATUS_PUSH_REMOTE_URL=''
# VCS_STATUS_REMOTE_BRANCH=master
# VCS_STATUS_REMOTE_NAME=origin
# VCS_STATUS_REMOTE_URL=git@github.com:pixelastic/oroshi
# VCS_STATUS_RESULT=ok-sync
# VCS_STATUS_TAG=''
# VCS_STATUS_WORKDIR=/home/tim/.oroshi
}
