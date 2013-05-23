# encoding : UTF-8
require "fileutils"
require "shellwords"
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
# A filepath is supposed to be of the following pattern
# /[...]/{letter}/{artist}/{year} - {album name}/{CDX}?/{track number} - {track
# name}.mp3
# For podcasts :
# /[...]/podcasts/{letter}/{name}/{year}/{number} - {name}.mp3
# For soundtracks :
# /[...]/soundtracks/{letter}/{movie}/{track number} - {track name}.mp3
# /[...]/soundtracks/{letter}/{saga}/{year} - {name}/{track number} - {track
# name}.mp3
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
		args.reject!{|f| File.extname(f).downcase!='.mp3'}.reject!{|f| !File.exists(f)}
		# Work with complete filepath
		args.map!{|f| File.expand_path(f)}

		unless args.size > 0
			raise MusicMetadataUpdate::ArgumentError, "You need to pass at least one file", ""
		end

		@files = args
	end


	def run

	end
end


