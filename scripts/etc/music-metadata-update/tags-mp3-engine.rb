# encoding : utf-8
require 'mp3info'
# Engine to read and write tags from mp3 files

class TagsMp3Engine
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

	def initialize(file)
		@file = file
		read_common_tags
	end

	# Meta-programming to read tags
	def method_missing method
		if @hash.has_key?(method.to_s)
			return @hash[method.to_s]
		else
			super
		end
	end

	# Set in an easy to access hash the main tags
	def read_common_tags
		begin
			Mp3Info.open(@file) do |mp3info|
				@hash = {
					'artist' => mp3info.tag.artist,
					'year'   => mp3info.tag.year,
					'album'  => mp3info.tag.album,
					'index'  => mp3info.tag.tracknum,
					'title'  => mp3info.tag.title
				}
			end
		rescue
			# Unable to read the file as an mp3 file, we'll feed it empty 
			# metadata
			@hash = {
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
				mp3info.tag.artist = @hash.artist
				mp3info.tag.year   = @hash.year
				mp3info.tag.album  = @hash.album
				mp3info.tag.index  = @hash.index
				mp3info.tag.title  = @hash.title
			end
	end

	


end

