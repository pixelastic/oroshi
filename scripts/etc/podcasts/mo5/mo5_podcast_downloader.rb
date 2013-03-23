# encoding : utf-8
require_relative '../podcast_downloader'

class MO5PodcastDownloader < PodcastDownloader

	def pre_run
		@list_url = 'http://mo5.com/mag/podcasts/itunes.xml'
	end

	def node_to_hash(node)
			title = node.xpath('./title').text
			url = node.xpath('./enclosure').attr('url').text
			date = DateTime.parse(node.xpath('./pubDate').text)

			# Parsing it a bit more
			matches = title.match(/podcast #([0-9]*) - (.*)$/i)
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

