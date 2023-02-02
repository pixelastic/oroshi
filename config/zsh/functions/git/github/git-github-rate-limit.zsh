# Display current GitHub rate limit
function git-github-ratelimit() {
  curl \
    -s \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN_READONLY" \
    https://api.github.com/rate_limit \
    | jx 'resources.core'
}
