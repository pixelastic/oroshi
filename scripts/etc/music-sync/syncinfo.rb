# encoding : utf-8
# Will read and write to .syncinfo files

class Syncinfo
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

	def initialize(directory)
		# Accepts files as well as directories
		directory = File.dirname(directory) unless File.directory?(directory)
		unless File.exists?(directory)
			raise Syncinfo::ArgumentError, "Invalid directory #{directory}", ""
		end
		@directory = directory
		@list = get_target_list
	end

	# Return filepath of the .syncinfo corresponding file
	def syncinfo_file
		File.join(@directory, ".syncinfo")
	end

	# Check if already has a syncinfo file
	def has_syncinfo?
		File.exists?(syncinfo_file)
	end

	# Read content of syncinfo file
	def get_target_list
		return [] unless has_syncinfo?
		File.read(syncinfo_file).split("\n")
	end

	# Rewrite list to file
	def write_list_to_file
		@list.sort!
		@list << ''
		File.open(syncinfo_file, "w") do |file|
			file.write(@list.join("\n"))
		end
	end

	# Check if contains a specific target
	def has_target?(target)
		@list.include?(target)
	end

	# Add a new target to the list
	def add_target(target)
		return if has_target?(target)
		@list << target
		write_list_to_file
	end

	# Removes a target from the list
	def remove_target(target)
		return unless has_target?(target)
		@list.delete(target)
		write_list_to_file
	end

end

