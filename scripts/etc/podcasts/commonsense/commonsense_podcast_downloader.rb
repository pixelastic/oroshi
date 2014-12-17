# encoding : utf-8
require_relative '../podcast_downloader'

class CommonSensePodcastDownloader < PodcastDownloader

  def pre_run
    @list_url = 'http://feeds.feedburner.com/dancarlin/commonsense?format=xml'
  end

  def node_to_hash(node)
    title = node.xpath('./title').text
    url = node.xpath('./guid').text
    date = DateTime.parse(node.xpath('./pubDate').text)

    matches = title.match(/Show ([0-9]*) - (.*)$/i)
    index = matches[1]
    title = matches[2]

    return {
      'index' => index,
      'title' => title,
      'url' => url,
      'date' => date,
    }
  end
end

