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
	def from_basedir
		# Deal only with the dirpath, not the file
		filepath = File.directory?(@file) ? @file : File.dirname(@file)

		split = filepath.split("/")
		# Artist is easy to spot
		artist = split[-2]
		# Album and year
		pattern = /^([0-9]*) - (.*)$/
		if match = split[-1].match(pattern)
			return {
				'year' => match[1],
				'album' => match[2],
				'artist' => artist
			}
		else
			return {
				'album' => split[-1],
				'artist' => artist
			}
		end
	end

	# Returns the root dir, the place where the file is saved, without all the 
	# metadata hierarchy
	def root_dir
		@file.split("/")[0..-5].join("/")
	end

	# Returns the metadata hierarchy of a filepath
	def metadata_hierarchy
		@file.split("/")[-4..-1].join("/")
	end

	def generate_filepath
		# Make every part of the filepath fat32 compatible
		fat32data = {}
		@data.each do |key, value|
			fat32data[key] = make_fat32_compliant(value)
		end

		return File.join(
			root_dir, 
			fat32data['artist'][0], 
			fat32data['artist'], 
			"#{fat32data['year']} - #{fat32data['album']}", 
			"#{fat32data['index']} - #{fat32data['title']}#{fat32data['ext']}"
		);
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

