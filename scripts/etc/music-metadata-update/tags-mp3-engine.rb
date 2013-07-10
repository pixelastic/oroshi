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
			update_tag(mp3info, 'artist', @data['artist'])
			update_tag(mp3info, 'year'  , @data['year'])
			update_tag(mp3info, 'album' , @data['album'])
			update_tag(mp3info, 'tracknum', @data['index'])
			update_tag(mp3info, 'title', @data['title'])
			# Useless tags
			update_tag(mp3info, 'comment', nil)
			update_tag(mp3info, 'genre', 255)
		end
	end

	# Update a tag in a mp3 file. Will not change anything if the value stays the 
	# same, will delete fields when value empty and will handle corner-cases
	def update_tag(mp3info, tag, value)
		# Do nothing if value already in the mp3 is same as new value
		return if mp3info.tag[tag] == value
		
		# Tracknumber must be int in v1, can be string in v2
		if tag == "tracknum"
			mp3info.tag1[tag] = value.to_i
			mp3info.tag2[tag] = value
			return
		end

		# Change inner tag representation
		mp3info.tag[tag] =  value
	end

	


end

