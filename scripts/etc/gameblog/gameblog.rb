# encoding : utf-8
require "fileutils"
# Will parse the Gameblog podcast list and download the latest episodes

class Gameblog

	def initialize
		@podcasts_dir = File.expand_path('~/local/tmp/gameblog/')
		@xml_file = File.join(@podcasts_dir, 'podcasts.xml')
		@download_delay = '1 day'

	end

	# Return the path of the podcasts.xml file
	def get_xml_list
		# No file, we download it
		unless File.exists?(@xml_file) 
			return download_xml_list()
		end

		# File still young enough, we keep it
		file_age = Time.now() - File.mtime(@xml_file)
		puts file_age


		# We download a new file
		return download_xml_list()

	end

	# Download podcasts.xml from the gameblog server
	def download_xml_list

	end
end

