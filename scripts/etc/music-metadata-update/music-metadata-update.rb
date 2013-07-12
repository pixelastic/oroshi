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
		metadata = MetadataEngine.new(file)

		unless metadata.tracklist.has_tracklist?
			puts "No .tracklist found, generate it first"
			return
		end

		# Update tags to reflect what's in the tracklist
		metadata.tags.artist = metadata.tracklist.artist
		metadata.tags.year   = metadata.tracklist.year
		metadata.tags.album  = metadata.tracklist.album
		metadata.tags.index  = metadata.tracklist.index
		metadata.tags.title  = metadata.tracklist.title
		metadata.tags.save

		# Update filepath to rename files based on new metadata
		metadata.filepath.artist = metadata.tracklist.artist
		metadata.filepath.year   = metadata.tracklist.year
		metadata.filepath.album  = metadata.tracklist.album
		metadata.filepath.index  = metadata.tracklist.index
		metadata.filepath.title  = metadata.tracklist.title
		metadata.filepath.save
	end
	
	def run
		@files.each do |file|
			update_metadata(file)
		end

	end

end


