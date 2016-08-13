# Helper methods used in the `ebook-` scripts
require 'English'
require 'awesome_print'
require 'fileutils'
require 'shellwords'
module EbookHelper
  # Keep only inputs that match the type, removing non-existing files and using
  # full filepath
  def clean_inputs(inputs, type)
    inputs = inputs.reject do |input|
      next true unless send("#{type.to_sym}?", input)
      next true unless File.exist?(input)
      false
    end
    inputs.map do |input|
      File.expand_path(input)
    end
  end

  def extname?(input, extensions)
    extname = File.extname(input)[1..-1]
    extensions.include?(extname)
  end

  def markdown?(input)
    extname?(input, %w(md mkd))
  end

  def mobi?(input)
    extname?(input, %w(mobi))
  end

  def epub?(input)
    extname?(input, %w(epub))
  end

  def fullpath(input, ext)
    basename = File.basename(input, File.extname(input))
    dirname = File.dirname(input)
    File.expand_path(File.join(dirname, "#{basename}.#{ext}"))
  end

  # Convert a markdown file to the specified format
  def convert_from_markdown(input, ext)
    output = fullpath(input, ext)
    txt = fullpath(input, 'txt')
    cover = fullpath(input, 'jpg')

    # Backup the existing file
    File.rename(output, "#{output}.bak") if File.exist?(output)

    # Convert input to .txt (ebook-convert does not accept markdown as
    # input)
    FileUtils.copy(input, txt)

    options = [
      txt.shellescape,
      output.shellescape,
      '--formatting-type markdown',
      '--paragraph-type off',
      "--chapter '//h:h2'"
    ]

    # Adding cover if found
    if File.exist?(cover)
      options << "--cover #{cover.shellescape}"
      options << '--preserve-cover-aspect-ratio'
    else
      puts 'WARNING: No cover file found, epub will have no cover'
    end

    puts "Converting to #{ext}"
    command = "ebook-convert #{options.join(' ')}"

    `#{command}`
    
    unless $CHILD_STATUS.success?
      puts 'Error while processing file'
      exit 1
    end

    # Removing the now useless txt file
    File.delete(txt)

    # Updating metadata
    puts 'Updating metadata'
    `ebook-metadata-update #{output.shellescape}`
  end

end
