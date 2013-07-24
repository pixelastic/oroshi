# encoding : utf-8
# Will mark every specified directory for synchronization with specified target
# This will add the codename of the target in a .syncinfo file in the directory
# Usage :
#  $ mark-for-sync ./dir1 [./dir2] sansa
require_relative "syncinfo"

class MarkForSync
	class Error < StandardError; end
	class ArgumentError < Error; end

	def initialize(*args)
		parse_args(*args)
	end

	# Make sure every arg is correct
	def parse_args(*args)
		# At least directory and target
		if args.size == 0
			raise MarkForSync::ArgumentError, "You need at least a target", ""
		end
		# Current dir is default dir
		if args.size == 1
			args.unshift('.')
		end
		# Last argument must be a target (ie. a custom name, not a filepath)
		if File.exists?(args[-1])
			raise MarkForSync::ArgumentError, "Last argument must be a target (ie. jukebox, sansa, etc)", ""
		end
		@target = args[-1]

		# Keep only existing directories
		@directories = []
		args[0..-2].each do |dir|
			dir = File.expand_path(dir)
			next unless File.exists?(dir)
			next unless File.directory?(dir)
			@directories << dir
		end
	end

	# Will mark all specified directories for synchronization
	def run
		@directories.each do |dir|
			Syncinfo.new(dir).add_target(@target)
		end
	end
end
