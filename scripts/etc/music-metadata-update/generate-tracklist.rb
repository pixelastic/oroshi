# encoding : UTF-8
require_relative "metadata-engine"

# Will create a .tracklist file containing metadata information about the 
# current album.
# This file will then be used by `mmu` to update file id3 tags. The initial 
# tracklist file is generated with data guessed from the filepath.
# Usage :
#  $ mktl ./file.mp3
#  $ mktl ./dir
#  $ mktl ./dir ./file.mp3 ./otherpath
# Options :
#  -f, --force : Overwrite existing .tracklist file if found

class GenerateTracklist
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

	def initialize(*args)
		parse_args(*args)
	end

	def parse_args(*args)
		@force = false
		@files = []

		args.each do |arg|
			# Check for force flag
			if arg=='-f' || arg=='--force'
				@force = true
			end
			# Skipping non-existing files
			next unless File.exists?(arg)
			@files << File.expand_path(arg)
		end
	end

	# Returns tracklist dirname
	def tracklist_dirname(filepath)
		return File.directory?(filepath) ? filepath : File.dirname(filepath)
	end
	# Returns filepath to the .tracklist file for any given file or dir
	def tracklist_filepath(filepath)
		File.join(tracklist_dirname(filepath), '.tracklist')
	end

	# Returns if specified file or dir has its own tracklist
	def has_tracklist?(filepath)
		File.exists?(tracklist_filepath(filepath))
	end

	# Generate tracklist file
	def generate_tracklist(filepath)
		return if has_tracklist?(filepath) && !@force
		File.open(tracklist_filepath(filepath), 'w') do |tracklist|
			tracklist.write(get_tracklist_content(filepath))
		end
	end

	# Get tracklist content
	def get_tracklist_content(filepath)
		metadata = MetadataEngine.new(filepath)
		# Tracklist header
		content = [
			metadata.filepath.artist, 
			metadata.filepath.year, 
			metadata.filepath.album,
			''
		]
		# Tracklist content
		Dir[File.join(tracklist_dirname(filepath), '*.*')].sort.each do |subfile|
			submetadata = MetadataEngine.new(subfile)
			content << "#{submetadata.filepath.index} - #{submetadata.filepath.title}"
		end

		return content.join("\n")
	end

	def run
		@files.each do |file|
			puts get_tracklist_content(file)
		end

	end

end

