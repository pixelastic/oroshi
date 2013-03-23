# encoding : utf-8
require 'open-uri'
require "fileutils"
require "shellwords"
require 'nokogiri'
# Base class for downloading a list of podcasts based on a RSS XML

class PodcastDownloader
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end
	class DirNotFoundError < Error; end
	class NoListUrlError < Error; end

	def initialize(*args)
		parse_args(*args)
		@download_delay = 24*60*60
		@xml_file = File.join(@podcasts_dir, 'list.xml')

		# Allow child classes to define the xml location
		@list_url = ''
		pre_run

		if @list_url == ''
			raise PodcastDownloader::NoListUrlError, "No url specified for the podcast list", ""
		end
	end

	# Must pass the directory where the podcasts are saved
	def parse_args(*args)
		unless args.size > 0
			raise PodcastDownloader::ArgumentError, "You need to pass at least the dir holding the podcasts", ""
		end

		@podcasts_dir = File.expand_path(args[0])
		unless File.directory?(@podcasts_dir)
			raise PodcastDownloader::DirNotFoundError,  "Unable to find #{@podcasts_dir}", ""
		end
	end

	# Must be redefined in child class with specific values
	def pre_run
		puts "You must define a `pre_run` method in your child class where you define `@list_url` to the RSS XML url"
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

	# Download xml file
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
			hash = node_to_hash(node)

			# Fixing some common issues with hashes
			hash['index'] = hash['index'].to_s
			hash['title'].gsub!('/', '-')
			hash['year'] = hash['date'].year.to_s

			# Saving it to the list
			list[hash['index']] = hash
		end

		return list
	end

	# Must be overriden in child classes to transforme a node to a hash
	def node_to_hash(node)
		puts "You must define a `node_to_hash` method in your child class to parse the Nokogiri nodes"
	end


	def run
		# Update the list
		update_xml_list

		# Check that we have every available podcast, and download them if not
		parse_podcasts_xml.each do |index, podcast|
			# Create a dir for each year
			year_dir = File.join(@podcasts_dir, podcast['year'])
			FileUtils.mkdir_p(year_dir)

			prefix = "%03d" % podcast['index']
			basename = "#{prefix} - #{podcast['title']}.mp3"
			filepath = File.join(year_dir, basename)

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

