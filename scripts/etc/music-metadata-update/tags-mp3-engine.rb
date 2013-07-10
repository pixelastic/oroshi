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
			Mp3Info.open(@file) do |mp3info|
				# Main tags
				mp3info.tag.artist = @data.artist
				mp3info.tag.year   = @data.year
				mp3info.tag.album  = @data.album
				mp3info.tag.index  = @data.index
				mp3info.tag.title  = @data.title
				# Useless tags
				mp3info.tag.comment = ''
				mp3info.tag.genre = ''
			end
	end

	


end

