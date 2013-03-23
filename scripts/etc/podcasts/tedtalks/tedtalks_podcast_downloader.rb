# encoding : utf-8
require_relative '../podcast_downloader'

class TedTalksPodcastDownloader < PodcastDownloader

	def pre_run
		@list_url = 'http://feeds.feedburner.com/TEDTalks_audio'
	end

	def node_to_hash(node)
			title = node.xpath('./itunes:subtitle').text
			index = node.xpath('jwplayer:talkId').text
			url = node.xpath('./enclosure').attr('url').text
			date = DateTime.parse(node.xpath('./pubDate').text)

			return {
				'index' => index,
				'title' => title,
				'url' => url,
				'date' => date,
			}
	end
end

