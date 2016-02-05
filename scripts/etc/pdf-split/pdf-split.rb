# encoding : UTF-8
require 'fileutils'
require 'shellwords'
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
      puts 'Usage :'
      puts '$ pdf-split input.pdf'
      puts '  Will create one pdf file for every page of input.pdf'
      puts '$ pdf-split input.pdf 7'
      puts '  Will extract page 7 of input.pdf'
      puts '$ pdf-split input.pdf 3 5'
      puts '  Will create a new pdf containing pages 3 to 5 of input.pdf'
      fail PdfSplit::ArgumentError,
           'You need to pass at least the input file',
           ''
    end
    file = File.expand_path(args[0])
    unless File.exist?(file)
      fail PdfSplit::FileNotFoundError,
           'The input file does not exists (#{input})', ''
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

    from_padded = from.to_s.rjust(3, '0')
    to_padded = to.to_s.rjust(3, '0')

    if from == to
      newbasename = "#{basename} - Page #{from_padded}#{extname}"
    else
      newbasename = "#{basename} - Page #{from_padded}-#{to_padded}#{extname}"
    end

    File.join(dirname, newbasename)
  end

  def extract_page_range(file, *args)
    from = args[0] || nil
    to = args[1] || args[0]
    if from != to
      puts "Extracting page #{from} to #{to}"
      cat = "#{from}-#{to}"
    else
      puts "Extracting page #{from}"
      cat = from
    end

    file = File.expand_path(file)
    output_file = extracted_filepath(file, from, to)
    options = [
      file.shellescape,
      'cat',
      cat,
      'output',
      output_file.shellescape
    ]
    `pdftk #{options.join(' ')}`
  end

  def get_page_number(file)
    output = `pdfinfo #{file.shellescape} | grep 'Pages:'`
    regexp = /^Pages:(\s*)([0-9]*)$/
    matches = regexp.match(output)
    matches[2].to_i
  end

  def extract_all_pages(file)
    max = get_page_number(file)
    for i in 1..max
      extract_page_range(file, i)
    end
  end

  def run
    return extract_page_range(@file, @from, @to) if @to
    return extract_page_range(@file, @from) if @from
    extract_all_pages(@file)
  end
end
