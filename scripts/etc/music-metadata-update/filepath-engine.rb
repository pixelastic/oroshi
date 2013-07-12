# encoding : UTF-8
require "fileutils"
# Engine to read and write metadata from a filepath.

class FilepathEngine
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

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
		pattern = /^([0-9]*) - (.*)$/
		if match = basename.match(pattern)
			return {
				'index' => match[1],
				'title' => match[2],
				'ext'   => extname
			}
		else
			return {
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
		# Deal only with the dirpath, not the file
		filepath = File.directory?(@file) ? @file : File.dirname(@file)

		data = {}
		split = filepath.split("/")

		# Last part can be a cd. Once found, we keep going as usual.
		if cd_dir?(split[-1])
			data['cd'] = split[-1]
			split.pop
		end

		# Artist is easy to spot, penultimate part.
		artist = split[-2]
		# Album and year
		pattern = /^([0-9]*) - (.*)$/
		if match = split[-1].match(pattern)
			data['year'] = match[1]
			data['album'] = match[2]
			data['artist'] = artist
		else
			data['album'] = split[-1]
			data['artist'] = artist
		end

		return data
	end

	# Check if specified dir is a CD dir
	def cd_dir?(path)
		path = path.split('/').pop if path['/']
		return path =~ /^CD([0-9])$/
	end

	# Check if filepath has a CD directory
	def has_cd_dir?
		split = @file.split('/')
		return cd_dir?(split[-2])
	end

	# Returns the root dir, the place where the file is saved, without all the 
	# metadata hierarchy
	def root_dir
		return @file.split("/")[0..-6].join('/') if has_cd_dir?
		return @file.split("/")[0..-5].join('/')
	end

	# Returns the metadata hierarchy of a filepath
	def metadata_hierarchy
		@file.split("/")[-5..-1].join("/") if has_cd_dir?
		@file.split("/")[-4..-1].join("/")
	end

	def generate_filepath
		# Make every part of the filepath fat32 compatible
		fat32data = {}
		@data.each do |key, value|
			fat32data[key] = make_fat32_compliant(value)
		end

		path = []
		path << root_dir
		path << fat32data['artist'][0]
		path << fat32data['artist']
		path << "#{fat32data['year']} - #{fat32data['album']}"
		path << fat32data['cd'] if fat32data['cd']
		path <<	"#{fat32data['index']} - #{fat32data['title']}#{fat32data['ext']}"

		return File.join(*path)
	end

	# FAT32 has a list of illegal characters, we strip those
	def make_fat32_compliant(string)
		string.gsub(/([\?\/\*\|!:;"<>])/, "").strip.gsub(/ {2,}/," ")
	end


	# Rename file based on metadata
	def save
		# Change the inner filepath representation
		old_file = @file
		@file = generate_filepath
		# Move file on disk
		unless old_file == @file
			puts "Renamed to #{metadata_hierarchy}"
			FileUtils.mv(old_file, @file) 
		end
	end

end

