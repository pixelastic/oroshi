# encoding : UTF-8
require "fileutils"
require "shellwords"
# Will import files from a digital camera and resize them to a format better
# suited for easy viewing.


class CameraExtract
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end
	class DirNotFoundError < Error; end

	attr_reader :input, :output

	# Set input and output dirs
	def initialize(*args)
		@default_output = '~/Photos/tmp'
		@resize = 800

		parse_args(*args)
	end

	def parse_args(*args)
		unless args.size > 0
			raise CameraExtract::ArgumentError, "You need to pass at least the input dir", ""
		end
		input = File.expand_path(args[0])
		unless File.exists?(input)
			raise CameraExtract::DirNotFoundError, "The input dir does not exists (#{input})", ""
		end

		if args.size > 1
			output = args[1]
		else
			output = @default_output
		end
		output = File.expand_path(output)
		
		@input = input
		@output = output
	end

	# Return a list of all files to extract
	def get_extract_list(dir)
		return Dir[File.join(dir, '**', '*.{JPG,jpg,MP4,mp4}')].sort
	end

	# Get the file creation date
	def get_created_date(file)
		return File.mtime(file).strftime("%Y-%m-%d")
	end

	# Import the file from the removable media to the laptop
	def import_file_on_disk(file)
			# Create an output directory if non-existent
			output_dir = File.join(@output, get_created_date(file))
			FileUtils.mkdir_p(output_dir)

			# Copy the file there
			extname = File.extname(file)
			basename = File.basename(file, extname) + extname.downcase
			target_file = File.join(output_dir, basename)
			puts "Importing #{basename}"
			FileUtils.mv file, target_file, :force => true

			return target_file
	end

	def optimise_image(file)
			basename = File.basename(file)
			dirname = File.dirname(file)
			
			# Creating compress subdir
			compress_dir = File.join(dirname, 'compress')
			compressed_file = File.join(compress_dir, basename)
			FileUtils.mkdir_p(compress_dir)

			puts "Converting to #{@resize}px"
			convert_options = [
				"convert #{file.shellescape}",
				"-resize #{@resize}",
				"#{compressed_file.shellescape}"
			]
			%x[#{convert_options.join(' ')}]

			# Optimising them
			puts "Optimising 80%"
			jpegoptim_options = [
				"jpegoptim -m80",
				"#{compressed_file.shellescape}"
			]
			%x[#{jpegoptim_options.join(' ')}]
	end

	# Delete the .thm (thumbnail movie) files left on the device
	def delete_thm_files
		Dir[File.join(@input, '**', '*.{thm,THM}')].sort.each do |file|
			puts "Deleting #{file}"
			File.delete(file)
		end
	end


	# Check if given file is an image
	def is_image?(file)
		extname = File.extname(file)[1..-1]
		return true if extname.downcase == "jpg"
	end

	def run
		extract_list = get_extract_list(@input)

		extract_list.each do |file|
			imported_file = import_file_on_disk(file)
			optimise_image(imported_file) if is_image?(imported_file)
		end

		# Delete useless files left on device
		delete_thm_files

	end
end


