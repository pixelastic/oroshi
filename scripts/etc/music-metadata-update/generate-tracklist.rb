# encoding : UTF-8
require "fileutils"
require "shellwords"
# Will create a .tracklist file containing metadata information about the 
# current album.
# This file will then be used by `mmu` to update file id3 tags. The initial 
# tracklist file is generated with data guessed from the filepath.
# Usage :
#  $ mktl ./file.mp3
#  $ mktl ./dir
#  $ mktl ./dir ./file.mp3 ./otherpath
# Options :
#  -f, --force : Overwrite existing .tracklist file if found

class GenerateTracklist
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

	def initialize(*args)
		parse_args(*args)
	end

	def parse_args(*args)
		@force = false
		@files = []

		args.each do |arg|
			# Check for force flag
			if arg=='-f' || arg=='--force'
				@force = true
			end
			# Skipping non-existing files
			next unless File.exists?(arg)
			@files << File.expand_path(arg)
		end
	end

	# Returns filepath to the .tracklist file for any given file or dir
	def tracklist_filepath(filepath)
		basename = File.directory?(filepath) ? filepath : File.dirname(filepath)
		File.join(basename, '.tracklist')
	end

	# Returns if specified file or dir has its own tracklist
	def has_tracklist?(filepath)
		File.exists?(tracklist_filepath(filepath))
	end

	def run
		@files.each do |file|
			puts tracklist_filepath(file)
		end

	end

end

