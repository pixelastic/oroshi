# encoding : UTF-8
# Engine to read metadata from a tracklist file

class TracklistEngine
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

	attr_reader :data

	def initialize(file)
		@file = file
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
		return @album_files = Dir.glob(File.join(dirname, '*.{mp3}')).sort
	end
	
	# Pad the index with leading zeroes
	def pad_index(index)
		"%0#{get_album_files.size.to_s.size}d" % index.to_i
	end

	# Generate the text content of the .tracklist
	def generate_content
		filepath = FilepathEngine.new(@file)
		#  Tracklist header
		content = [
			filepath.artist,
			filepath.year,
			filepath.album
		]
		# Add CD if present
		content << filepath.cd if filepath.cd

		# Blank line to separate header from tracklisting
		content << ''

		# Track list
		get_album_files.each do |subfile|
			submetadata = FilepathEngine.new(subfile)
			content << "#{pad_index(submetadata.index)} - #{submetadata.title}"
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

		blank_line_found = false
		get_content.split("\n").each do |track|
			# Keep skipping header lines until you get to an empty one
			if blank_line_found == false
				blank_line_found = true if track == ''
				next
			end

			match = track.match(pattern)
			tracks[match[1]] = match[2]
		end
		return tracks
	end

	# Returns a data hash of all the values
	def get_data
		return {} unless has_tracklist?
		split = get_content.split("\n")
		begin
			# Header
			data = {
				'artist' => split[0],
				'year' => split[1],
				'album' => split[2],
				'tracks' => get_tracks
			}
			#  Adding cd if present
			data['cd'] = (split[3] =~ /^CD([0-9])$/) ? split[3] : ''
			# Adding data about the current file (title and index)
			data.merge!(get_track_info)
		rescue
			puts "Corrupted .tracklist file!"
			data = {
				'artist' => '',
				'year'   => '',
				'album'  => '',
				'cd'     => '',
				'tracks' => []
			}
		end
		return data
	end

	# Returns index and title info for the specific file, based on data saved in 
	# tracklist
	def get_track_info
		return {} if File.directory?(@file)

		# We find the position of the file in the dir, and then find matching date 
		# for the file in the hash.
		index = pad_index(get_album_files.index(@file)+1)
		title = get_tracks[index]
		return {
			'index' => index,
			'title' => title
		}
	end

end

