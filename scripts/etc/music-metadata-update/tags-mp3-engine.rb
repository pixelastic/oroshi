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
		super unless @data.has_key?(key)
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

	# Update an mp3info.tag list to values passed in a hash
	def set_tags_to_file(mp3tags, hash)
		# Delete all tags that are not in the hash
		mp3tags.each do |tag, value|
			mp3tags[tag] = nil unless hash.has_key?(tag)
		end
		# Add every other key of hash that is not in the tag list
		hash.each do |key, value|
			mp3tags[key] = value
		end
	end

	# Save tags back into file
	def save
		puts "Rewriting id3 tags of #{File.basename(@file)}"

		Mp3Info.open(@file) do |mp3info|
			tag1 = {
				'artist' => @data['artist'],
				'year' => @data['year'],
				'album' => @data['album'],
				'tracknum' => @data['index'].to_i,
				'title' => @data['title']
			}
			tag2 = {
				'TPE1' => @data['artist'],
				'TYER' => @data['year'],
				'TALB' => @data['album'],
				'TRCK' => @data['index'],
				'TIT2' => @data['title']
			}

			set_tags_to_file(mp3info.tag1, tag1)
			set_tags_to_file(mp3info.tag2, tag2)
		end

		# Mp3Info.open(@file) do |mp3info|
		# 	puts "-----"
		# 	puts "tag1 :"
		# 	p mp3info.tag1
		# 	puts "tag2 :"
		# 	p mp3info.tag2
		# 	puts "tag :"
		# 	p mp3info.tag
		# end
	end

	


end

