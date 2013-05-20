# encoding : UTF-8
require "fileutils"
require "shellwords"
# Script to split a pdf file in multiple files.
# Usage
# $ pdf-split Input.pdf
# Will split the pdf in X pdf, X being the number of pages of input. They will
# be named "Input - Page 1.pdf"
#
# $ pdf-split Input.pdf 3 5
# Will create a new pdf, of pages 3 to 5 of Input.pdf named "Input - Pages
# 3-5.pdf"
#
# $ pdf-split Input.pdf 7
# Will extract only page 7 from Input.pdf and name it "Input - Page 7.pdf"


class PdfSplit
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end
	class FileNotFoundError < Error; end


	def initialize(*args)
		parse_args(*args)
	end

	def parse_args(*args)
		unless args.size > 0
			puts "Usage :"
			puts "$ pdf-split input.pdf"
			puts "  Will create one pdf file for every page of input.pdf"
			puts "$ pdf-split input.pdf 7"
			puts "  Will extract page 7 of input.pdf"
			puts "$ pdf-split input.pdf 3 5"
			puts "  Will create a new pdf containing pages 3 to 5 of input.pdf"
			raise PdfSplit::ArgumentError, "You need to pass at least the input file", ""
		end
		file = File.expand_path(args[0])
		unless File.exists?(file)
			raise PdfSplit::FileNotFoundError, "The input file does not exists (#{input})", ""
		end
		@file = file

		@from = args [1] || nil
		@to = args[2] || nil
	end

	# Get the output name of the extracted file
	def extracted_filepath(file, from, to)
		file = File.expand_path(file)
		dirname = File.dirname(file)
		extname = File.extname(file)
		basename = File.basename(file, extname)
				
		if from==to
			newbasename = "#{basename} - Page #{from}#{extname}"
		else
			newbasename = "#{basename} - Page #{from}-#{to}#{extname}"
		end

		return File.join(dirname, newbasename)
	end

	def extract_page_range(file, *args)
		from = args[0] || nil
		to = args[1] || args[0]
		if from!=to
			puts "Extracting page #{from} to #{to}"
		else
			puts "Extracting page #{from}"
		end

		file = File.expand_path(file)
		output_file = extracted_filepath(file, from, to)
		gs_options = [
			'-dBATCH',
			'-dNOPAUSE',
			'-dQUIET',
			'-sDEVICE=pdfwrite',
			"-dFirstPage=#{from}",
			"-dLastPage=#{to}",
			"-sOutputFile=#{output_file.shellescape}",
			file.shellescape
		]
		
		%x[gs #{gs_options.join(' ')} 2>/dev/null]
	end

	def get_page_number(file)
		output = %x[pdfinfo #{file.shellescape} | grep 'Pages:']
		regexp = /^Pages:(\s*)([0-9]*)$/
		matches = regexp.match(output)
		return matches[2].to_i
	end

	def extract_all_pages(file)
		max = get_page_number(file)
		for i in 1..max
			extract_page_range(file, i)
		end
	end

	def run
		if @to
			return extract_page_range(@file, @from, @to)
		end
		if @from
			return extract_page_range(@file, @from)
		end
		return extract_all_pages(@file)
	end
end


