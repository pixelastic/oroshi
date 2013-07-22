# encoding : utf-8
# Will read and write to .syncinfo files

class Syncinfo
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

	def initialize(directory)
		unless File.exists?(directory) && File.directory?(directory)
			raise Syncinfo::ArgumentError, "Invalid directory #{directory}", ""
		end
		@directory = directory
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
	def write_list_to_file(list)
		list.sort!
		File.open(syncinfo_file, "w") do |file|
			file.write(list.join("\n"))
		end
	end

	# Add a new target to the list
	def add_target(target)
		list = get_target_list
		basename = File.basename(@directory)
		if list.include?(target)
			puts "Target #{target} already in .syncinfo for #{basename}"
		else
			list << target
			write_list_to_file(list)
			puts "Target #{target} added to .syncinfo for #{basename}"
		end
	end

end

