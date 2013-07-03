# encoding : UTF-8
require_relative "metadata-engine"
# Will update a file metadata based on the .tracklist file found in its 
# directory.

class MusicMetadataUpdate
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

	def initialize(*args)
		parse_args(*args)
	end

	# Tidy the list of input files
	def parse_args(*args)
		@files = []
		args.each do |file|
			next unless File.exists?(file)
			@files << File.expand_path(file)
		end
	end

	# Update id3 and filepath metadata based on tracklist info
	def update_metadata(file)
		metadata = MetadataEngine(file)
		puts metadata.tracklist

	end
	
	def run
		@files.each do |file|
			update_metadata(file)
		end

	end

end


