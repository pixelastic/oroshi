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
		@data = from_basedir.merge(from_basefile)
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
		return "podcasts" if basedir =~ /\/podcasts\//
		return "soundtracks" if basedir =~ /\/soundtrack\//
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
	def root_dir
		split = @file.split("/")
		return split[0..(split.index(get_type)-1)].join("/")
	end

	# Returns the metadata hierarchy of a filepath
	def metadata_hierarchy
		split = @file.split("/")
		return split[split.index(get_type)..-1].join("/")
	end

	# FAT32 has a list of illegal characters, we strip those
	def make_fat32_compliant(value)
		value.to_s.gsub(/([\?\/\*\|:;"<>])/, "").strip.gsub(/ {2,}/," ").gsub('’', "'")
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


	# Get data from the file basename.
	# > 07 - Hexagone.mp3
	#     index : 7
	#     title : Hexagone
	# > Big Blue Dress.mp3
	#     title : Big Blue Dress
	def from_basefile
		# Nothing if it's a directory
		return {} if File.directory?(@file)
		
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
		default = {
			'type' => get_type,
			'artist' => '',
			'year' => '',
			'album' => '',
			'cd' => ''
		}

		# Get metadata based on type of music
		case default['type']
		when "podcasts"
			data = from_basedir_podcasts
		when "music"
			data = from_basedir_music
		else
			raise FilepathEngine::NoTypeError, "Unknown type : #{get_type}", ""
		end

		return default.merge(data)
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

	# Generate filepath for the current file
	def generate_filepath
		case @data['type']
		when "music"
			return generate_filepath_music
		when "podcasts"
			return generate_filepath_podcasts
		else
			raise FilepathEngine::NoTypeError, "Unable to generate filepath for type #{data['type']}", ""
		end
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

	def generate_filepath_podcasts
		data = get_fat32_compliant_data

		path = []
		path << root_dir
		path << "podcasts"
		path << artist_first_letter(data['artist'])
		path << data['artist']
		# Album if album specified
		path << data['album'] if data['album'] != ''
		path <<	"#{data['index']} - #{data['title']}#{data['ext']}"

		return path.join("/")
	end

	# Rename file based on metadata
	def save
		# Change the inner filepath representation
		old_file = @file
		@file = generate_filepath
		# Move file on disk
		if old_file != @file
			if File.exists?(@file)
				puts "WARNING: Can't rename file, destination already exists!"
				return
			end
			puts "Renamed to #{metadata_hierarchy}"
			FileUtils.mkdir_p(File.dirname(@file))
			FileUtils.mv(old_file, @file) 
		end
	end

end

