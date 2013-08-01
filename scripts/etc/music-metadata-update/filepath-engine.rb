# encoding : UTF-8
require "fileutils"
# Engine to read and write metadata from a filepath.

class FilepathEngine
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end
	class NoTypeError < Error; end

	attr_reader :data	

	def initialize(file)
		@file = file
		@data = get_data
	end
	
	# Meta-programming to read and write
	def method_missing(method, *args)
		is_set_method = (method.to_s =~ /(.*)=$/)
		key = is_set_method ? $1 : method.to_s
		# No such key
		super unless @data.has_key?(key)
		# Set
		return @data[key] = args[0] if is_set_method
		# Get
		return @data[key]
	end


	# Get the basedir of the filepath
	def basedir
		File.directory?(@file) ? @file : File.dirname(@file)
	end
	
	# Get the type (music, podcast, soundtrack) based on the filepath
	def get_type
		return "misc" if basedir =~ /\/misc\// || basedir =~ /\/misc$/
		return "nature" if basedir =~ /\/nature\//
		return "podcasts" if basedir =~ /\/podcasts\//
		return "soundtracks" if basedir =~ /\/soundtracks\//
		return "music"
	end

	# Check if specified dir is a CD dir
	def cd_dir?(path)
		path = path.split('/').pop if path['/']
		return path =~ /^CD([0-9])/
	end

	# Check if filepath has a CD directory
	def has_cd_dir?
		split = @file.split('/')
		return cd_dir?(split[-2])
	end

	# Returns the root dir, the place where the file is saved, without all the 
	# metadata hierarchy
	# eg. "/media/0123-4567/MUSIC/"
	def root_dir
		split = basedir.split("/")
		return split[0..(split.index(get_type)-1)].join("/")
	end

	# Returns the metadata hierarchy of a filepath
	# eg. "/soundtracks/C/Conan/"
	def metadata_hierarchy
		split = basedir.split("/")
		return split[split.index(get_type)..-1].join("/")
	end

	# FAT32 has a list of illegal characters, we strip those
	def make_fat32_compliant(value)
		# Remove characters not allowed in fat32
		value = value.to_s.gsub(/([\?\/\*\|:;"”“<>])/, "").strip
		# Double spaces
		value = value.gsub(/ {2,}/," ")
		# Bad quotes
		value = value.gsub('’', "'")
		return value
	end

	# Returns the data hash in a fat32 compliant way
	def get_fat32_compliant_data
		fat32data = {}
		@data.each do |key, value|
			fat32data[key] = make_fat32_compliant(value)
		end
		return fat32data
	end

	# Get first letter of an artist name
	def artist_first_letter(string)
		string[0].upcase.tr("ÀÂÄÉÈËÊÎÏÖÔÛÜ", "AAAEEEEIIOOUU")
	end

	def get_data
		default = {
			'type' => get_type,
			'artist' => '',
			'year' => '',
			'album' => '',
			'cd' => '',
			'index' =>'',
			'title' => ''
		}
		return default.merge(from_basedir).merge(from_basefile)
	end


	# Get data from the file basename.
	# > 07 - Hexagone.mp3
	#     index : 7
	#     title : Hexagone
	# > Big Blue Dress.mp3
	#     title : Big Blue Dress
	def from_basefile
		# Nothing if it's a directory
		return {} if File.directory?(@file)

		case get_type
		when "misc"
			return from_basefile_misc
		when "music"
			return from_basefile_music
		when "nature"
			return from_basefile_nature
		when "podcasts"
			return from_basefile_podcasts
		when "soundtracks"
			return from_basefile_soundtracks
		else
			raise FilepathEngine::NoTypeError, "Unknown type : #{get_type}", ""
		end
	end

	# Misc files does not have an index but contain both artist and title
	def from_basefile_misc
		extname = File.extname(@file)
		basename = File.basename(@file, extname)
		pattern = /([^-]*) - (.*)/
		match = basename.match(pattern)
		return {
			'artist' => match[1],
			'title' => match[2],
			'ext' => extname
		}
	end

	# Extracting information from the basefile for music files
	def from_basefile_music
		extname = File.extname(@file)
		basename = File.basename(@file, extname)
		pattern = /^([0-9\.]*) - (.*)$/
		if match = basename.match(pattern)
			return {
				'index' => match[1],
				'title' => match[2],
				'ext'   => extname
			}
		else
			return {
				'index' => "00",
				'title' => basename,
				'ext'   => extname
			}
		end
	end
	
	def from_basefile_nature
		from_basefile_music
	end

	def from_basefile_podcasts
		from_basefile_music
	end

	def from_basefile_soundtracks
		from_basefile_music
	end


	# Get the artist, year and album from the dir basename
	# > /../R/Renaud/1975 - Amoureux de Paname/
	#   artist : Renaud
	#   year : 1975
	#   album : Amoureux de Paname
	# > /../A/Amy McDonald/This is the Life/
	#   artist : Amy McDonald
	#   album : This is the Life
	# > /../B/Boby Lapointe/1997 - Best Of/CD1/
	#   artist : Boby Lapointe
	#   year : 1997
	#   album : Best Of
	#   cd : CD1
	def from_basedir
		# Get metadata based on type of music
		case get_type
		when "misc"
			return from_basedir_misc
		when "music"
			return from_basedir_music
		when "nature"
			return from_basedir_nature
		when "podcasts"
			return from_basedir_podcasts
		when "soundtracks"
			return from_basedir_soundtracks
		else
			raise FilepathEngine::NoTypeError, "Unknown type : #{get_type}", ""
		end
	end

	# Metadata info guessed by the basedir for a misc file
	def from_basedir_misc
		return {}
	end

	# Extract data from filepath for music files
	def from_basedir_music
		split = basedir.split("/")
		data = {}

		# Last part can be a cd. Once found, we keep going as usual.
		if cd_dir?(split[-1])
			data['cd'] = split[-1]
			split.pop
		end

		# Artist is easy to spot, penultimate part.
		data['artist'] = split[-2]

		# Album and year
		pattern = /^([0-9]*) - (.*)$/
		if match = split[-1].match(pattern)
			data['year'] = match[1]
			data['album'] = match[2]
		else
			data['album'] = split[-1]
		end

		return data
	end

	# Metadata guessed from the basedir for nature files
	def from_basedir_nature
		split = basedir.split("/")
		return {
			'artist' => 'Nature',
			'album' => split[-1]
		}
	end

	def from_basedir_podcasts
		# We start at the podcasts level
		split = metadata_hierarchy.split("/")
		data = {}

		# Artist
		data['artist'] = split[2]
		# As a default, we'll set the album the same as the artist
		data['album'] = data['artist']

		# If no more directory, we stop here
		return data if split.size == 3

		# Otherwise, the next dir is an album
		data['album'] = split[3]
		# It can even be a year
		data['year'] =  split[3] if split[3] =~ /^([0-9]{4})$/
		return data
	end

	def from_basedir_soundtracks
		split = metadata_hierarchy.split("/")
		data = {}

		# We first check the last dir, to see if it's a CD one or not
		if split.last =~ /^CD.*/
			data['cd'] = split.last
			split.pop
		end

		# We then check if the last one contains a date
		date_pattern = /^([0-9]{4}) - (.*)/
		if split.last =~ date_pattern
			match = split.last.match(date_pattern)
			data['year'] = match[1]
			data['album'] = match[2]
			
			# This can also be a Season soundtrack, so we need to include the name of
			# the show in the album
			if data['album'] =~ /^(Season|Saison)/
				data['album'] = "#{split[-2]} - #{data['album']}"
			end
		else
			data['album'] = split.last
		end

		# Artist is the same as the album for soundtracks
		data['artist'] = data['album']

		return data
	end

	# Generate filepath for the current file
	def generate_filepath
		case @data['type']
		when "misc"
			return generate_filepath_misc
		when "music"
			return generate_filepath_music
		when "nature"
			return generate_filepath_nature
		when "podcasts"
			return generate_filepath_podcasts
		when "soundtracks"
			return generate_filepath_soundtracks
		else
			raise FilepathEngine::NoTypeError, "Unable to generate filepath for type #{data['type']}", ""
		end
	end

	# Generate a filepath for a misc file
	def generate_filepath_misc
		data = get_fat32_compliant_data

		path = []
		path << root_dir
		path << "misc"
		path << "#{data['artist']} - #{data['title']}#{data['ext']}"

		return path.join("/")
	end

	# Generate a filepath for a music file
	def generate_filepath_music
		data = get_fat32_compliant_data

		path = []
		path << root_dir
		path << "music"
		path << artist_first_letter(data['artist'])
		path << data['artist']
		path << "#{data['year']} - #{data['album']}"
		# Adding cd subdir if cd specified
		path << data['cd'] if data['cd'] != ""
		path <<	"#{data['index']} - #{data['title']}#{data['ext']}"

		return path.join("/")
	end

	# Generate the filepath for a nature song
	def generate_filepath_nature
		data = get_fat32_compliant_data

		path = []
		path << root_dir
		path << "nature"
		path << data['album']
		path << "#{data['index']} - #{data['title']}#{data['ext']}"

		return path.join("/")
	end

	def generate_filepath_podcasts
		data = get_fat32_compliant_data

		path = []
		path << root_dir
		path << "podcasts"
		path << artist_first_letter(data['artist'])
		path << data['artist']
		# For podcasts, we sometimes use the year as the album, or a named
		# directory, or if none is found, we use the artist. So, if the album is
		# the same as the artist, we need not write it in the filepath.
		if data['album'] != "" && data['album'] != data['artist']
			path << data['album']
		end
		path <<	"#{data['index']} - #{data['title']}#{data['ext']}"

		return path.join("/")
	end

	def generate_filepath_soundtracks
		data = get_fat32_compliant_data
		# Note: Soundtracks are harder than other music file as their filepath can
		# contain a "saga" subfolder (like Batman or Harry Potter), or even several
		# (like Final Fantasy, and one subfolder for each episode).
		# To handle those files, we'll cheat and we'll only rename the basefile and
		# one or two upper dirs, depending on the info we have, but never above.

		path = []

		# Easy to get the basefile
		path << "#{data['index']} - #{data['title']}#{data['ext']}"
		# Adding the cd if one is set
		path.unshift(data['cd']) if data['cd'] != ''
		# We then grab the album
		album = data['album']
		# The album is a season
		if album =~ /(Season|Saison)/
			split_album = album.split(" - ")
			serie = split_album[0]
			season = split_album[1..-1].join(" - ")
			# We add the season subdir
			path.unshift("#{data['year']} - #{season}")
			# And the serie subdir
			path.unshift(serie)
		else
			# Otherwise, we just add the album, or album with a year if one is
			# specified
			if data['year'] == ''
				path.unshift(data['album'])
			else
				path.unshift("#{data['year']} - #{data['album']}")
			end
		end

		# We keep the dir_root and add our prefix
		split = @file.split("/")
		dir_root = split[0..(-path.size-1)]
		filepath = (dir_root + path).join("/")

		return filepath
	end

	# Rename file based on metadata
	def save
		# Change the inner filepath representation
		old_file = @file
		@file = generate_filepath
		# Move file on disk
		if old_file != @file
			if File.exists?(@file)
				puts "WARNING: Can't rename #{file}, destination already exists!"
				return
			end
			puts "Renamed to #{metadata_hierarchy}/#{File.basename(@file)}"
			FileUtils.mkdir_p(File.dirname(@file))
			FileUtils.mv(old_file, @file) 
		end
	end

end

