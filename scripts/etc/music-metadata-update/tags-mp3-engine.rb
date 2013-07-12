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
			delete_useless_tags(mp3info)
		end

		Mp3Info.open(@file) do |mp3info|
			puts "-----"
			puts "tag1 :"
			p mp3info.tag1
			puts "tag2 :"
			p mp3info.tag2
			puts "tag :"
			p mp3info.tag
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
		mp3info.tag2.TPOS = ""
	end

	def update_title(mp3info, value)
		mp3info.tag1.title = value
		mp3info.tag2.TIT2 = value
	end

	def delete_useless_tags(mp3info)
		# Genre
		mp3info.tag1.genre = 255
		mp3info.tag2.TCON = ""
		# Comments
		mp3info.tag1.comments = ""
		mp3info.tag2.COMM = ""
		mp3info.tag2.TXXX = ""
		mp3info.tag2.PRIV = ""
		
		# Recording date
		mp3info.tag2.TDRC = ""
		mp3info.tag2.TDAT = ""
		mp3info.tag2.TIME = ""
		mp3info.tag2.TRDA = ""
		# Secondary artists
		mp3info.tag2.TCOM = ""
		mp3info.tag2.TEXT = ""
		mp3info.tag2.TIPL = ""
		mp3info.tag2.TPE2 = ""
		mp3info.tag2.TPE3 = ""
		mp3info.tag2.TPE4 = ""
		mp3info.tag2.TPUB = ""
		mp3info.tag2.TSOP = ""
		# UUID
		mp3info.tag2.UFID = ""
		mp3info.tag2.TSRC = ""
		mp3info.tag2.MCDI = ""
		# Popularimeter
		mp3info.tag2.POPM = ""
		# Length
		mp3info.tag2.TLEN = ""
		# Beat per minute
		mp3info.tag2.TBPM = ""
		# Embedded lyrics
		mp3info.tag2.USLT = ""
		# Media type
		mp3info.tag2.TMED = ""
		# Language
		mp3info.tag2.TLAN = ""
		# Software used for encoding
		mp3info.tag2.TSSE = ""

		# Unknown tags
		mp3info.tag2.disc_number = ""
		mp3info.tag2.disc_total = ""
		mp3info.tag2.XSOP = ""
	end

	


end

