# PNG-related methods
module PngHelper
  # Check if file is a png
  def png?(input)
    File.extname(input).casecmp('.png').zero?
  end

  # Check if file is transparent
  def transparent?(input)
    options = [
      "-format '%[channels]'",
      input.shellescape
    ]
    raw = `identify #{options.join(' ')}`.chomp
    raw['rgba']
  end

  # Compress a PNG file
  def compress_png(input, quality = 80, output = nil)
    # Override file if no output selected
    output = input if output.nil?

    # PNGQuant does not allow update in place, so we save in a temp file
    output_tmp = Tempfile.new('temp_png').path

    options = [
      input.shellescape,
      '--force',
      "--quality 01-#{quality}",
      "--output #{output_tmp.shellescape}"
    ]

    command = "pngquant #{options.join(' ')}"
    `#{command}`

    # Move the tmp file back to the real output
    FileUtils.mv(output_tmp, output)

    output
  end

  # Trim the image, removing whitespace around it
  def trim(input)
    options = [
      input.shellescape,
      '-trim',
      input.shellescape
    ]
    command = "convert #{options.join(' ')}"
    `#{command}`
  end
end
