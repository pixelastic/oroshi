# encoding : utf-8
require_relative '../podcast_downloader'

class CNWPodcastDownloader < PodcastDownloader

  def pre_run
    @list_url = 'http://cnw.podomatic.com/rss2.xml'
  end

  def node_to_hash(node)
    title = node.xpath('./title').text
    url = node.xpath('./enclosure').attr('url').text
    date = DateTime.parse(node.xpath('./pubDate').text)

    matches = title.match(/Episode ([0-9]*)( - (.*))?$/i)
    index = matches[1]
    if (matches[2]) 
      title = matches[3]
    end

    return {
      'index' => index,
      'title' => title,
      'url' => url,
      'date' => date,
    }
  end
end

