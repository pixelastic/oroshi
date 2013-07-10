# encoding : utf-8
require 'mp3info'
# Engine to read and write tags from mp3 files

class TagsMp3Engine
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

	attr_reader :data

	def initialize(file)
		@file = file
		read_common_tags
	end

	# Meta-programming to read and write
	def method_missing(method, *args)
		is_set_method = (method.to_s =~ /(.*)=$/)
		key = is_set_method ? $1 : method.to_s
		# No such key
		super unless @data[key]
		# Set
		return @data[key] = args[0] if is_set_method
		# Get
		return @data[key]
	end

	# Read common tags into @data
	def read_common_tags
		begin
			Mp3Info.open(@file) do |mp3info|
				@data = {
					'artist' => mp3info.tag.artist,
					'year'   => mp3info.tag.year.to_s,
					'album'  => mp3info.tag.album,
					'index'  => mp3info.tag.tracknum.to_s,
					'title'  => mp3info.tag.title
				}
			end
		rescue
			# Unable to read the file as an mp3 file, we'll feed it empty 
			# metadata
			@data = {
				'artist' => '', 
				'year' => '', 
				'album' => '', 
				'index' => '', 
				'title' => '' 
			}
		end
	end

	# Save tags back into file
	def save
		puts "Rewriting id3 tags of #{File.basename(@file)}"

		Mp3Info.open(@file) do |mp3info|
			# Main tags
			update_artist(mp3info, @data['artist'])
			update_year(mp3info, @data['year'])
			update_album(mp3info, @data['album'])
			update_index(mp3info, @data['index'])
			update_title(mp3info, @data['title'])
			# Useless tags
			delete_comment(mp3info)
			delete_genre(mp3info)
			# TODO : Some more cleaning of useless fields. cf. The Virgin Suicides.
		end
	end

	# Note : The Ruby Mp3Info gem seems to have som bugs when trying to manually 
	# change both values based on .tag1/.tag2 and .tag. It is safer to manually 
	# use the .tag1/tag2 version.

	def update_artist(mp3info, value)
		mp3info.tag1.artist = value
		mp3info.tag2.TPE1 = value
	end

	def update_year(mp3info, value)
		mp3info.tag1.year = value
		mp3info.tag2.TYER = value
	end

	def update_album(mp3info, value)
		mp3info.tag1.album = value
		mp3info.tag2.TALB = value
	end

	def update_index(mp3info, value)
		mp3info.tag1.tracknum = value.to_i
		mp3info.tag2.TRCK = value
	end

	def update_title(mp3info, value)
		mp3info.tag1.title = value
		mp3info.tag2.TIT2 = value
	end

	def delete_genre(mp3info)
		mp3info.tag1.genre = 255
		mp3info.tag2.TCON = ""
	end

	def delete_comment(mp3info)
		mp3info.tag1.comment = ""
		mp3info.tag2.COMM = ""
	end

	


end

