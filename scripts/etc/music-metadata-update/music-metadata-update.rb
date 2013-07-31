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
		if args.size == 0
			args = [File.expand_path('.')]
		end

		@files = []
		args.each do |file|
			next unless File.exists?(file)
			file = File.expand_path(file)

			# If target is a dir, we add all music files in this dir
			if File.directory?(file)
				@files += Dir.glob(File.join(file, '**', '*.{mp3,ogg}')).map{|i| File.expand_path(i)}.sort
			else
				@files << file
			end
		end
	end

	# Update id3 and filepath metadata based on tracklist info
	def update_metadata(file)
		metadata = MetadataEngine.new(file)

		# Special renaming case for misc files that do not need the tracklist
		if metadata.filepath.get_type == "misc"
			metadata.tags.artist = metadata.filepath.artist
			metadata.tags.year   = metadata.filepath.year
			metadata.tags.album  = metadata.filepath.album
			metadata.tags.cd     = metadata.filepath.cd
			metadata.tags.index  = metadata.filepath.index
			metadata.tags.title  = metadata.filepath.title
			metadata.tags.save
			return
		end

		unless metadata.tracklist.has_tracklist?
			puts "No .tracklist found for #{file}, generating it now."
			%x[generate-tracklist #{file.shellescape}]
			metadata = MetadataEngine.new(file)
		end

		# Update tags to reflect what's in the tracklist
		metadata.tags.artist = metadata.tracklist.artist
		metadata.tags.year   = metadata.tracklist.year
		metadata.tags.album  = metadata.tracklist.album
		metadata.tags.cd     = metadata.tracklist.cd
		metadata.tags.index  = metadata.tracklist.index
		metadata.tags.title  = metadata.tracklist.title
		metadata.tags.type   = metadata.tracklist.type
		metadata.tags.save

		# Update filepath to rename files based on new metadata
		metadata.filepath.artist = metadata.tracklist.artist
		metadata.filepath.year   = metadata.tracklist.year
		metadata.filepath.album  = metadata.tracklist.album
		metadata.filepath.cd     = metadata.tracklist.cd
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


