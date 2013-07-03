# encoding : UTF-8
# Engine to read and write metadata from a filepath.

class FilepathEngine
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

	def initialize(file)
		@file = file
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
				'index' => match[1].to_i,
				'title' => match[2]
			}
		else
			return {
				'title' => basename
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
				'year' => match[1].to_i,
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

	# Return a hash of all the values extracted from filepath
	def to_h
		return @hash if @hash
		return @hash = from_basedir.merge(from_basefile)
	end

	# Easy access to every key
	def to_s
		to_h
	end
	def artist
		to_h['artist']
	end
	def year
		to_h['year']
	end
	def album
		to_h['album']
	end
	def index
		to_h['index']
	end
	def title
		to_h['title']
	end

end

