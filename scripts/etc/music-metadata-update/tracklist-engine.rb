# encoding : UTF-8
require_relative "filepath-engine"
# Engine to read metadata from a tracklist file

class TracklistEngine
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

	attr_reader :data

	def initialize(file)
		@file = file
		@filepath_engine = FilepathEngine.new(@file)
		@data = get_data
	end

	# Meta-programming to read tags
	def method_missing method
		if @data.has_key?(method.to_s)
			return @data[method.to_s]
		else
			super
		end
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
		return @album_files if @album_files
		return @album_files = Dir.glob(File.join(dirname, '*.{mp3,ogg}')).sort
	end

	# Returns the content of the .tracklist file
	def get_content
		return '' unless has_tracklist?
		return @content if @content
		return @content = File.read(tracklist_filepath)
	end

	# Pad the index with leading zeroes
	def pad_index(index)
		"%0#{[get_album_files.size.to_s.size, 2].max}d" % index.to_i
	end

	# Returns a data hash of all the values
	def get_data
		return {} unless has_tracklist?
		split = get_content.split("\n")
		data = {
			'type'   => '',
			'artist' => '',
			'year'   => '',
			'album'  => '',
			'cd'     => '',
			'tracks' => {}
		}
		track_pattern = /^([0-9]*) - (.*)$/
		blank_line_found = false


		split.each do |line|
			# header
			if blank_line_found == false
				if line == ''
					blank_line_found = true
					next
				end
				# Splitting name/value by the first equal sign
				line_split = line.split("=")
				data[line_split[0]] = line_split[1..-1].join("=")
				next
			end

			# tracks
			match = line.match(track_pattern)
			data['tracks'][match[1]] = match[2]
		end

		# We also add information about the current track info if a file is
		# specified
		unless File.directory?(@file)
			# We find the index from the filepath and get the matching title in the
			# tracklist
			index = @filepath_engine.index
			title = data['tracks'][index]
			data['index'] = index
			data['title'] = title
		end

		return data
	end

	# Generate the text content of the .tracklist
	def generate_content
		#  Tracklist header
		content = [
			"type=#{@filepath_engine.type}",
			"artist=#{@filepath_engine.artist}",
			"year=#{@filepath_engine.year}",
			"album=#{@filepath_engine.album}",
			"cd=#{@filepath_engine.cd}"
		]

		# Blank line to separate header from tracklisting
		content << ''

		# Track list
		get_album_files.each do |subfile|
			submetadata = FilepathEngine.new(subfile)
			content << "#{pad_index(submetadata.index)} - #{submetadata.title}"
		end
		
		return content.join("\n")
	end
end

