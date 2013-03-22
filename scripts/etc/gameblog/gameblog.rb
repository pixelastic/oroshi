# encoding : utf-8
require 'open-uri'
require "fileutils"
require "shellwords"
require 'nokogiri'
# Will parse the Gameblog podcast list and download the latest episodes

class Gameblog

	def initialize
		@podcasts_dir = File.expand_path('~/local/tmp/gameblog/')
		@xml_file = File.join(@podcasts_dir, 'podcasts.xml')
		@list_url = 'http://www.gameblog.fr/podcasts.xml'
		@download_delay = 24*60*60

	end

	# Return the path of the podcasts.xml file
	def update_xml_list
		# No file, we download it
		unless File.exists?(@xml_file) 
			download_xml_list()
		end

		# File still young enough, we keep it
		if (Time.now() - File.mtime(@xml_file)).to_i < @download_delay
			puts "podcasts.xml is up to date"
			return
		end

		# We download a new file
		download_xml_list()
	end

	# Download podcasts.xml from the gameblog server
	def download_xml_list
		puts "Downloading podcasts.xml"
		File.open(@xml_file, "w") do |xml_file|
			open(@list_url, 'r') do |url_file|
				xml_file.write(url_file.read)
			end
		end
	end

	# Parse the podcasts.xml file and return an array of all episodes
	def parse_podcasts_xml
		doc = Nokogiri::XML(File.new(@xml_file))
		list = {}

		for node in doc.root.xpath("//item")
			# Getting basic information from the xml
			title = node.xpath('./title').text
			link = node.xpath('./link').text
			author = node.xpath('./author').text
			length = node.xpath('./enclosure').attr('length')
			date = DateTime.parse(node.xpath('./pubDate').text)
			description = node.xpath('./description').text

			# Parsing it a bit more
			matches = title.match(/Podcast (N°)?([0-9]*)(.*)? : (.*)/i)
			index = matches[2]
			title = matches[4]

			# Making it a big element
			list[index] = {
				'index' => index,
				'title' => title,
				'url' => link,
				'date' => date,
				'description' => description
			}
		end

		return list
	end


	def run
		# Update the list
		update_xml_list

		podcasts = parse_podcasts_xml

	
		puts podcasts
	end
end

