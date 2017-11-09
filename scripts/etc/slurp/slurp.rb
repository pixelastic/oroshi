require 'shellwords'

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
      '--no-server-response', # Keep output readable
    ]
  end

  def parse_args(*args)
    if args.empty?
      raise Slurp::ArgumentError, 'You need to pass at least the url to download', ''
    end
  end

  def run
    options = @default_options + @options
    `wget #{options.join(' ')} #{@url}`
   end
end
