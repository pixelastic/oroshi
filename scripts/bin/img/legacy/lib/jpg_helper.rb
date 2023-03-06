# JPG-related methods
module JpgHelper
  # Check if file is a jpg
  def jpg?(input)
    extname = File.extname(input)
    ['.jpg', '.jpeg'].include?(extname.downcase)
  end

  # Compress a JPG file
  def compress_jpg(input, quality = 80, output = nil)
    unless output.nil?
      FileUtils.cp(input, output)
      input = output
    end

    options = [
      '-q -p -f',
      "--max=#{quality}",
      '--strip-all',
      '--all-progressive',
      input.shellescape
    ]

    command = "jpegoptim #{options.join(' ')}"
    `#{command}`

    return output unless output.nil?
    input
  end
end
