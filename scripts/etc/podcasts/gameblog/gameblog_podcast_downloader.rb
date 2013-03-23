# encoding : utf-8
require_relative '../podcast_downloader'

class GameblogPodcastDownloader < PodcastDownloader

	def pre_run
		@list_url = 'http://www.gameblog.fr/podcasts.xml'
	end

	def node_to_hash(node)
			title = node.xpath('./title').text
			url = node.xpath('./enclosure').attr('url').text
			date = DateTime.parse(node.xpath('./pubDate').text)

			matches = title.match(/Podcast (N°)?([0-9]*)(.[^\:]*)? : (.*)$/i)
			index = matches[2]
			title = matches[4]

			return {
				'index' => index,
				'title' => title,
				'url' => url,
				'date' => date,
			}
	end
end

