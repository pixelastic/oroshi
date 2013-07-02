# encoding : UTF-8
require "fileutils"
require "shellwords"
require_relative "mp3"
# Will read metadata from a mp3 file based on its current metadata, filepath
# and .tracklist file, and rewrite them and possibly rename the file.
#
# It will first read the .tracklist file if present. Then, it will parse the
# filepath to get its informations. It will update informations based on either
# the filepath or the .tracklist, depending of the metadata.
#
# Some filesystem does not allow ?, /, or : characters in file names, which are
# quite often present in song names. To circumvent this, we'll use the
# .tracklist file to store all relevant data, regardless of the filesystem.
#
# The script can be run several times on the same file without any loss of
# information (apart from useless tags).
#
# 


class MusicMetadataUpdate
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end
	class FileNotFoundError < Error; end

	def initialize(*args)
		parse_args(*args)
	end

	def parse_args(*args)
		# Keep only valid mp3 files
		args = args.reject{|f| File.extname(f).downcase!='.mp3'}.reject{|f| !File.exists?(f)}
		# Work with complete filepath
		args.map!{|f| File.expand_path(f)}

		unless args.size > 0
			raise MusicMetadataUpdate::ArgumentError, "You need to pass at least one file", ""
		end

		@files = args
	end

	# Check if a tracklist file is present
	def has_tracklist?(file)
		dirname = File.dirname(File.expand_path(file))
		return File.exists?(File.join(dirname, '.tracklist'))
	end

	# Generates a .tracklist file containing all the album metadata
	def generate_tracklist(mp3)
		return if has_tracklist?(mp3.filepath)

		# Content header
		content = [mp3.artist, mp3.year, mp3.album, '']
		# Tracklists
		dirname = File.dirname(mp3.filepath)
		Dir[File.join(dirname, '*.mp3')].sort.each do |file|
			filemp3 = Mp3.new(file)
			content << "#{filemp3.index} - #{filemp3.title}"
		end

		# Generate the file
		File.open(File.join(dirname, '.tracklist'), 'wb') do |file|
			file.write(content.join("\n"))
		end
	end

	def run
		@files.each do |file|
			mp3 = Mp3.new(file)
			generate_tracklist(mp3)
		end

	end
end


