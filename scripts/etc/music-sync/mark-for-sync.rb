# encoding : utf-8
# Will mark every specified directory for synchronization with specified target
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
		if args.size < 2
			raise SynclistAdd::ArgumentError, "You need at least of target directory and a target", ""
		end
		# Last argument must be a target (ie. a custom name, not a filepath)
		if File.exists?(args[-1])
			raise SynclistAdd::ArgumentError, "Last argument must be a target (ie. jukebox, sansa, etc)", ""
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

	def run
		@directories.each do |dir|
			Syncinfo.new(dir).add_target(@target)
		end
	end
end
