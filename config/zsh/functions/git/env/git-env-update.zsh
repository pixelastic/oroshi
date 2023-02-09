function git-env-update() {
  gitstatus_query 'MY'

  # Get all available vars with typeset -m 'VCS_STATUS_*'

  # Are we in a git directory?
  export GIT_DIRECTORY_IS_REPOSITORY="0"
  [[ $VCS_STATUS_RESULT == "ok-sync" ]] && GIT_DIRECTORY_IS_REPOSITORY="1"
  export GIT_DIRECTORY_ROOT=$VCS_STATUS_WORKDIR
  export GIT_DIRECTORY_IS_DIRTY=$VCS_STATUS_HAS_UNSTAGED
  export GIT_DIRECTORY_HAS_STAGED_FILES=$VCS_STATUS_HAS_STAGED

  export GIT_BRANCH_CURRENT=$VCS_STATUS_LOCAL_BRANCH
  export GIT_COMMIT_CURRENT=$VCS_STATUS_COMMIT
  export GIT_REMOTE_CURRENT=$VCS_STATUS_REMOTE_NAME
  export GIT_REMOTE_URL=$VCS_STATUS_REMOTE_URL

  export GIT_STASH_EXISTS=$VCS_STATUS_STASHES

  export GIT_DIRECTORY_IS_GITHUB="0"
  [[ $VCS_STATUS_REMOTE_URL == *github.com* ]] && GIT_DIRECTORY_IS_GITHUB="1"


# VCS_STATUS_ACTION=''
# VCS_STATUS_COMMITS_AHEAD=3
# VCS_STATUS_COMMITS_BEHIND=0
# VCS_STATUS_COMMIT_ENCODING=''
# VCS_STATUS_COMMIT_SUMMARY='Don'\''t search in .git folders'
# VCS_STATUS_HAS_CONFLICTED=0
# VCS_STATUS_HAS_STAGED=0
# VCS_STATUS_HAS_UNSTAGED=1
# VCS_STATUS_HAS_UNTRACKED=1
# VCS_STATUS_INDEX_SIZE=1241
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
}
