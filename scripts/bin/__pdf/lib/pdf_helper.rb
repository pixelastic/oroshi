require 'fileutils'
require 'awesome_print'
require 'shellwords'
require_relative './command_helper'

# Main entry point to all PDF-related methods
module PdfHelper
  include CommandHelper

  # Return a hash of info about the PDF obtained through `pdfinfo`
  def info(input)
    return nil unless pdf?(input)
    command = "pdfinfo #{input.shellescape}"
    result = command_stdout(command)
    info = {}
    result.each_line do |line|
      key, value = line.chomp.split(':')
      info[key] = value.strip
    end
    info
  end

  # Check if the input file is a PDF file
  def pdf?(input)
    command = "file #{input.shellescape}"
    result = command_stdout(command)
    _, type = result.chomp.split(':')
    !(type =~ /PDF Document/i).nil?
  end

  # Return the number of pages of the PDF
  def page_count(input)
    info = info(input)
    return nil if info.nil?
    info['Pages'].to_i
  end

  # Extract a specific page or range from one PDF
  def split(input: nil, output: nil, range: nil)
    output = input.gsub(/\.pdf$/, "_#{range}.pdf") if output.nil?

    options = [
      input.shellescape,
      "cat #{range}",
      "output #{output.shellescape}"
    ]
    command = "pdftk #{options.join(' ')}"

    success = command_success?(command)
    return output if success
  end

  # Return the text contained in the PDF
  def text(input)
    command = "pdftotext #{input.shellescape} -"
    command_stdout(command)
  end

  # Extract internal images
  def images(input)
    # Create subdir to extract pictures
    basename = File.basename(input, File.extname(input))
    dirname = File.dirname(input)
    dirpath = File.join(dirname, basename)
    FileUtils.mkdir_p(dirpath)

    options = [
      '-png',
      input.shellescape,
      "#{dirpath.shellescape}/image"
    ]
    command = "pdfimages #{options.join(' ')}"
    success = command_success?(command)
    return nil unless success

    Dir["#{dirpath}/*.png"]
  end
end
