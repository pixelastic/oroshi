# encoding : utf-8
require_relative "tags-mp3-engine"
# Engine to read and write metadata from a the file tags

class TagsEngine
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end
	class NoEngineError < Error; end

	def initialize(file)
		@file = file
		case File.extname(@file)
		when ".mp3"
			@engine = TagsMp3Engine.new(@file)
		else
			raise TagsEngine::NoEngineError, "No tag engine for #{@file}", ""
		end
	end
	
	# If not method found in TagsEngine, send it to specific 
	# Engine
	def method_missing method
		return @engine.send(method)
	end



end
 

