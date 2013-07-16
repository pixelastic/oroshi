# encoding : utf-8
require 'shellwords'
# Engine to read and write tags from ogg files

class TagsOggEngine
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end
	class NoBinaryFound < Error; end

	attr_reader :data

	def initialize(file)
		@file = file
		check_dependencies
		read_common_tags
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
	
	# Check that command line tools are installed
	def check_dependencies
		if %x[which vorbiscomment] == ''
			raise TagsOggEngine::NoBinaryFound, "Unable to find `vorbiscomment` executable", ""
		end
	end

	# Get all the tags from the file
	def get_all_tags
		taglist = %x[vorbiscomment -l #{@file.shellescape}].split("\n")
		tags = {}
		taglist.each do |line|
			key,value = line.split("=")
			tags[key] = value
		end
		return tags
	end


	# Read common tags into @data
	def read_common_tags
		tags = get_all_tags
		@data = {
			'artist' => tags['artist'] || '',
			'year' => tags['date'] || '',
			'album' => tags['artist'] || '',
			'cd' => tags['discnumber'] || '',
			'index' => tags['tracknumber'] || '',
			'title' => tags['title'] || '',
			'genre' => tags['genre']
		}
	end

	# Save tags back into file
	def save
		puts "Rewriting ogg tags of #{File.basename(@file)}"
		
		options = [
			'-w',
			"-t artist=#{@data['artist'].shellescape}",
			"-t year=#{@data['year'].shellescape}",
			"-t album=#{@data['album'].shellescape}",
			"-t tracknumber=#{@data['index'].shellescape}",
			"-t title=#{@data['title'].shellescape}",
		]
		options << "-t discnumber=#{@data['cd']}" if @data['cd'] != ''
		# Adding genre if predefined one
		options << "-t genre=Podcast" if @data['type'] == "podcasts"
		options << "-t genre=Soundtrack" if @data['type'] == "soundtracks"

		%x[vorbiscomment #{options.join(' ')} #{@file.shellescape}]

	end

	


end

