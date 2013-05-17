# encoding: utf-8
require "shellwords"
# Update one dir with the content of another. It will add new files, delete old
# files and will not touch identical files. It will also skip any versioning
# files.
# The goal of this script is to easily sync a file on a portable device to the
# content of a git directory on my laptop, without having to clone the entire
# repository (and possibly big history).
# Usage
# $ update-dir ~/source /media/dest

class UpdateDir
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end
	class DirNotFoundError < Error; end

	def initialize(*args)
		parse_args(*args)
	end

	def parse_args(*args)
		unless args[0]
			raise UpdateDir::ArgumentError, "You need to pass the source dir", ""
		end
		from = File.expand_path(args[0])
		unless File.exists?(from)
			raise UpdateDir::DirNotFoundError, "The source dir does not exists (#{from})", ""
		end

		unless args[1]
			raise UpdateDir::ArgumentError, "You need to pass the destination dir", ""
		end
		to = File.expand_path(args[1])
		unless File.exists?(to)
			raise UpdateDir::DirNotFoundError, "The destination dir does not exists (#{to})", ""
		end
		
		@to = to
		@from = from
	end

	def get_rsync_options(from, to)
		# We are very careful to add a trailing slash to the source
		from = from+'/' unless from[-1]=='/'

		options = [
			'--recursive', # To copy subdirectories
			'--verbose', # To see what I'm doing
			'--archive', # To preserve as much attributes as possible'
			'--update', # To not touch unmodified files
			'--delete', # To delete files in dest that are no longer in source
			'--prune-empty-dirs', # To, well, prune empty directories
			'--compress', # To compress files when transferring
			'--modify-window=1', # Allow for potential FAT32 timestamp error

			# Exclude versioning files
			"--exclude '- .git/'", 
			"--exclude '- .gitignore'",
			"--exclude '- .gitmodules'",
			"--exclude '- .hg/'",
			"--exclude '- .hgignore'",
			# Exclude temporary dirs
			"--exclude '- tmp/*'",

			from.shellescape,
			to.shellescape,
		]
		return options
	end

	def execute(cmd)
		IO.popen(cmd) do |io| 
			while (line = io.gets) do 
				puts line 
			end
		end
	end

	def run
		options = get_rsync_options(@from, @to)
		puts "# Updating #{@to} with files from #{@from}"
		# puts "rsync #{options.join(' ')}"
		execute("rsync #{options.join(' ')}")
	end
end

