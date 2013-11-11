# encoding : UTF-8
require "fileutils"
require "shellwords"
# Will import files from a digital camera and resize them to a format better
# suited for easy viewing.
# Usage :
#  $ camera-extract /path/to/sd/card /local/path [--resize max_size] [--optim
#  optimisation_percentage]


class CameraExtract
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end
	class DirNotFoundError < Error; end

	attr_reader :input, :output

	# Set input and output dirs
	def initialize(*args)
		@default_resize = 800
    @default_optim = 80

		parse_args(*args)
	end

	def parse_args(*args)
		if args.size < 2
      puts "Usage :"
      puts "$ camera-extract /path/to/sd/card /local/path/to/extract [--resize max_size] [--optim optimisation_percentage]"
      exit
		end
    
    @input = File.expand_path(args[0])
    @output = File.expand_path(args[1])
    
    if !File.exists?(@input)
      puts "#{@input} unreachable."
      exit
    end

    if !File.exists?(@output)
      FileUtils.mkdir_p(@output)
      puts "Creating #{@output}"
    end

    @resize = args.include?('--resize') ? args[args.index('--resize')+1] : @default_resize
    @optim = args.include?('--optim') ? args[args.index('--optim')+1] : @default_optim

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
			puts "Optimising #{@optim}%"
			jpegoptim_options = [
				"jpegoptim -m#{@optim}",
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


