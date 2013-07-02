# encoding : UTF-8
require "fileutils"
require "shellwords"
require "date"
# Will import files from the Doxie Go scanner, compress them and order them by
# date


class DoxieExtract
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end
	class DirNotFoundError < Error; end

	attr_reader :input, :output

	# Set input and output dirs
	def initialize(*args)
		@default_input = '/media/DOXIE/DCIM/'
		@default_output = '~/Photos/tmp'
		@resize = 800

		parse_args(*args)
	end

	def parse_args(*args)
		args[0] = args[0] || @default_input
		args[1] = args[1] || @default_output

		input = File.expand_path(args[0])
		unless File.exists?(input)
			raise DoxieExtract::DirNotFoundError, "The input dir does not exists (#{input}), make sure Doxie is pluggued in and switched on", ""
		end

		output = File.expand_path(args[1])
		unless File.exists?(output)
			raise DoxieExtract::DirNotFoundError, "The input dir does not exists (#{output})", ""
		end

		@input = input
		@output = output
	end

	# Return a list of all files to extract
	def get_extract_list(dir)
		return Dir[File.join(dir, '**', '*.{JPG,jpg}')].sort
	end


	def run
		extract_list = get_extract_list(@input)

		# The Doxie Go is not equipped with an internal clock, so all scans are
		# timestamped from the same date. Instead of using the scanning date, I'll
		# have to use the extracting date.
		extract_list.each do |file|
			# Create an output directory for today
			day = DateTime.now.strftime("%Y-%m-%d")
			output_dir = File.join(@output, day)
			FileUtils.mkdir_p(output_dir)

			# Copy the file there
			extname = File.extname(file).downcase
			filedate = DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")
			targetfile = File.join(output_dir, "__" + filedate + extname)
			
			basename = File.basename(targetfile)
			basedir = File.dirname(targetfile)
			puts "Importing #{basename}"
			FileUtils.mv file, targetfile, :force => true

			# Compressing the file
			puts "Compressing #{basename}"
			%x[compress --resize 1280 #{targetfile.shellescape}]

			# Trashing full files and putting compressed one in its place
			compressdir = File.join(basedir, 'compress')
			compressfile = File.join(compressdir, basename)
			FileUtils.mv compressfile, targetfile, :force => true
			
		end

	end
end


