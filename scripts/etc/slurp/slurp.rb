# encoding : utf-8
require "shellwords"

class Slurp
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end
	class DirNotFoundError < Error; end

	def initialize(*args)
		parse_args(*args)

		@url = args[-1]
		@options = args[0..-2]

		@default_options = [
			'--adjust-extension', # Save as html and css if header says so
			'--span-hosts',       # Download from external sources
			'--convert-links',    # Allow local browsing
			'--page-requisites',  # Download css, images and js
			'--continue',         # Resume partial downloads
			'--no-parent',        # Never go higher in hierarchy         
		]
	end

	def parse_args(*args)
		unless args.size > 0
			raise Slurp::ArgumentError, "You need to pass at least the url to download", ""
		end

	end

 	def run
		options = @default_options + @options
		%x[wget #{options.join(' ')} #{@url}]
 	end

end

