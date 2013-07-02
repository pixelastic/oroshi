#!/usr/bin/env ruby
require "fileutils"
require "shellwords"
# Will compress specified files and output them in a ./compress subdirectory

class Compress

	def initialize(*args)
		@files = args
		@resize = 800
		@quality = 80

		# Optional arguments
		if args.include?('--resize')
			@resize = args[args.index('--resize')+1].to_i
		end
		if args.include?('--quality')
			@quality = args[args.index('--quality')+1].to_i
		end
	end

	def check_files
		@files.map! { |file| File.expand_path(file) }
		@files.select!{ |file| File.exists?(file) }
	end

	def run
		check_files

		@files.each do |file|
			# Ste the compress dir
			compressdir = File.join(File.dirname(file), 'compress')
			FileUtils.mkdir_p(compressdir)

			basename = File.basename(file)
			compress_file = File.join(compressdir, basename)
			convert_options = [
				'convert',
				file.shellescape,
				'-resize',
				@resize,
				compress_file.shellescape
			]
			puts "Converting #{basename} to #{@resize}px"
			%x[#{convert_options.join(' ')}]

			optim_options = [
				'jpegoptim',
				"-m#{@quality}",
				compress_file.shellescape
			]
			puts "Optimising #{basename} to #{@quality}%"
			%x[#{optim_options.join(' ')}]
			
		end

	end
end
