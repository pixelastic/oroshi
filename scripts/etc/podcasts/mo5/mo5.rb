# encoding : utf-8
require 'open-uri'
require "fileutils"
require "shellwords"
require 'nokogiri'
# Will parse the mo5 podcast list and download the latest episodes

class MO5
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end
	class DirNotFoundError < Error; end

	def initialize(*args)
		parse_args(*args)

		@xml_file = File.join(@podcasts_dir, 'itunes.xml')
		@list_url = 'http://mo5.com/mag/podcasts/itunes.xml'
		@download_delay = 24*60*60

	end

	def parse_args(*args)
		unless args.size > 0
			raise MO5::ArgumentError, "You need to pass at least the dir holding the podcasts", ""
		end

		@podcasts_dir = File.expand_path(args[0])
		unless File.directory?(@podcasts_dir)
			raise MO5::DirNotFoundError,  "Unable to find #{@podcasts_dir}", ""
		end
	end

	# Return the path of the podcasts.xml file
	def update_xml_list
		# No file, we download it
		unless File.exists?(@xml_file) 
			download_xml_list()
		end

		# File still young enough, we keep it
		if (Time.now() - File.mtime(@xml_file)).to_i < @download_delay
			puts "Podcast list is up to date"
			return
		end

		# We download a new file
		download_xml_list()
	end

	# Download xml from the gameblog server
	def download_xml_list
		puts "Downloading #{File.basename(@xml_file)}"
		File.open(@xml_file, "w") do |xml_file|
			open(@list_url, 'r') do |url_file|
				xml_file.write(url_file.read)
			end
		end
	end

	# Parse the xml file and return an array of all episodes
	def parse_podcasts_xml
		doc = Nokogiri::XML(File.new(@xml_file))
		list = Hash.new

		for node in doc.root.xpath("//item")
			# Getting basic information from the xml
			title = node.xpath('./title').text
			description = node.xpath('./itunes:subtitle').text
			url = node.xpath('./enclosure').attr('url').text
			date = DateTime.parse(node.xpath('./pubDate').text)

			# Parsing it a bit more
			matches = title.match(/podcast #([0-9]*) - (.*)$/i)
			index = matches[1]
			title = matches[2]

			# Fixing some issues with special chars in titles
			title.gsub!('/', '-')

			# Making it a big element
			list[index] = {
				'index' => index,
				'title' => title,
				'url' => url,
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

		# Check that we have every available podcast, and download them if not
		podcasts.each do |index, podcast|
			# Create a dir for each year
			year = podcast['date'].year.to_s
			FileUtils.mkdir_p(File.join(@podcasts_dir, year))

			prefix = "%03d" % podcast['index']
			basename = "#{prefix} - #{podcast['title']}.mp3"
			filepath = File.join(@podcasts_dir, year, basename)

			next if File.exists?(filepath)

			# Downloading the missing podcasts
			puts "Downloading \"#{basename}\""
			wget_options = [
				'wget',
				'--continue',
				'--timestamping=off',
				'--server-response=off',
				'--verbose',
				podcast['url'].shellescape,
				"-O #{filepath.shellescape}"
			]
			%x[#{wget_options.join(' ')}]

		end

		
	end
end

