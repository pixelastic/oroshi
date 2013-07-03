# encoding : UTF-8
require_relative "filepath-engine"
# Wrapper for reading and writing music metadata. Includes metadatas from 
# filepath, id3 and tracklist sources. Changing one of the values updates the 
# source accordingly.

class MetadataEngine
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

	def initialize(file)
		@file = File.expand_path(file)
	end

	# Returns the filepath engine
	def filepath
		return @filepath if @filepath
		return @filepath = FilepathEngine.new(@file)
	end

end

