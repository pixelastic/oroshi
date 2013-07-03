# encoding : UTF-8
# Engine to read metadata from a tracklist file

class TracklistEngine
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

	def initialize(file)
		@file = file
	end
	
	# Returns tracklist dirname
	def dirname
		return File.directory?(@file) ? @file : File.dirname(@file)
	end

	# Returns filepath to the .tracklist file
	def tracklist_filepath
		File.join(dirname, '.tracklist')
	end

	# Returns if file already has a tracklist
	def has_tracklist?
		File.exists?(tracklist_filepath)
	end

	# Returns the list of music file in the same directory
	def get_album_files
		return Dir.glob(File.join(dirname, '*.{mp3}')).sort
	end

	# Returns the text content of the tracklist file
	def generate_content
		filepath = FilepathEngine.new(@file)
		#  Tracklist header
		content = [
			filepath.artist,
			filepath.year,
			filepath.album,
			''
		]
		# Track list
		get_album_files.each do |subfile|
			submetadata = FilepathEngine.new(subfile)
			content << "#{submetadata.index} - #{submetadata.title}"
		end

		return content.join("\n")

	end




end

