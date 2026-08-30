# Fetch an RSS feed and extract its title
# Usage: getRssTitle <url>
function getRssTitle() {
  local url=$1

  curl --silent "$url" | xml-get '.rss.channel.title'
}
