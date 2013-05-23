# encoding : UTF-8

class Mp3
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end
	class NotMp3Error < Error; end
	class FileNotFoundError < Error; end

	def initialize(filepath)
		@filepath = File.expand_path(filepath)
		if File.extname(@filepath).downcase != '.mp3'
			raise Mp3::NotMp3Error, "Given file is not an mp3", ""
		end
		if !File.exists?(@filepath)
			raise Mp3::FileNotFoundError, "File not found", ""
		end

		@metadatas_filepath = get_metadatas_from_filepath	
	end

	# Guess metadata from a filepath
	def get_metadatas_from_filepath
		data = {}
		split = @filepath.split('/')

		# Track number and title
		extname = File.extname(@filepath)
		basename = File.basename(@filepath, extname)
		pattern = /^([0-9]*) - (.*)$/
		if match = basename.match(pattern)
			data['index'] = match[1].to_i
			data['title'] = match[2]
		else
			data['title'] = basename			
		end

		# Album and year
		dirname = split[-2]
		pattern = /^([0-9]*) - (.*)$/
		if match = dirname.match(pattern)
			data['year'] = match[1].to_i
			data['album'] = match[2]
		else
			data['album'] = dirname			
		end

		# Artist
		data['artist'] = split[-3]

		return data
	end

	def filepath_title
		@metadatas_filepath['title']
	end
	def filepath_index
		@metadatas_filepath['index']
	end
	def filepath_year
		@metadatas_filepath['year']
	end
	def filepath_album
		@metadatas_filepath['album']
	end
	def filepath_artist
		@metadatas_filepath['artist']
	end


end



