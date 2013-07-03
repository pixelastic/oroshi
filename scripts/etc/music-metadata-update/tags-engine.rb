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

	def artist
		@engine.artist
	end
	def year
		@engine.year
	end
	def album
		@engine.album
	end
	def index
		@engine.index
	end
	def title
		@engine.title
	end



end
 

