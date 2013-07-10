# encoding : UTF-8
# Engine to read metadata from a tracklist file

class TracklistEngine
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

	def initialize(file)
		@file = file
		@hash = get_hash
	end

	# Meta-programming to read tags
	def method_missing method
		if @hash.has_key?(method.to_s)
			return @hash[method.to_s]
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
		return Dir.glob(File.join(dirname, '*.{mp3}')).sort
	end

	# Generate the text content of the .tracklist
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
		album_files = get_album_files
		album_files.each do |subfile|
			submetadata = FilepathEngine.new(subfile)
			index = "%0#{(album_files.size/10).floor + 1}d" % submetadata.index
			content << "#{index} - #{submetadata.title}"
		end

		return content.join("\n")
	end

	# Returns the content of the .tracklist file
	def get_content
		return '' unless has_tracklist?
		return @content if @content
		return @content = File.read(tracklist_filepath)
	end

	# Returns array of tracks from file content
	def get_tracks
		tracks = {}
		pattern = /^([0-9]*) - (.*)$/
		get_content.split("\n")[4..-1].each do |track|
			match = track.match(pattern)
			tracks[match[1]] = match[2]
		end
		return tracks
	end

	# Returns a hash of all the values
	def get_hash
		return {} unless has_tracklist?
		split = get_content.split("\n")
		begin
			# Header
			hash = {
				'artist' => split[0],
				'year' => split[1],
				'album' => split[2],
				'tracks' => get_tracks
			}
			hash.merge!(get_track_info)
		rescue
			puts "Corrupted .tracklist file!"
			hash = {
				'artist' => '',
				'year'   => '',
				'album'  => '',
				'tracks' => []
			}
		end
		return hash
	end

	# Returns index and title info for the specific file, based on data saved in 
	# tracklist
	def get_track_info
		return {} if File.directory?(@file)

		# We find the position of the file in the dir, and then find matching date 
		# for the file in the hash.
		index = get_album_files.index(@file)+1
		title = get_tracks[index]
		return {
			'index' => index,
			'title' => title
		}
	end

end

