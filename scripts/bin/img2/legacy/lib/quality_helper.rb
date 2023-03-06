require 'tempfile'
require 'shellwords'

# Quality related methods
module QualityHelper
  def dssim_lower_bound
    0.004
  end

  def dssim_upper_bound
    0.005
  end

  # Convert a file to a temporary png
  def temp_png(input)
    return false if png?(input)

    # Create the temp directory
    tmp_dir = File.join(Dir.tmpdir, 'img', 'run')
    FileUtils.mkdir_p(tmp_dir)

    initial_ext = File.extname(input)

    # Find a unique path to save the temp file
    tmp_file = Tempfile.new()
    tmp_basename = File.basename(tmp_file.path)
    tmp_path = File.join(tmp_dir, "#{tmp_basename}#{initial_ext}")

    # Copy the file there and convert it to png
    FileUtils.cp(input, tmp_path)
    png_path = convert(tmp_path, 'png')

    # Delete the original jpg file
    File.delete(tmp_path)

    # Return the final png path
    png_path
  end

  # Return a DSSIM score between two files
  def dssim(original, compressed)
    # Only works on png files
    original = temp_png(original) unless png?(original)
    compressed = temp_png(compressed) unless png?(compressed)

    difference = `dssim #{original.shellescape} #{compressed.shellescape}`

    value = difference.strip.split("\t")[0].to_f
    value
  end

  # Are two files similar?
  def similar?(input, compressed)
    score = dssim(input, compressed)
    score <= dssim_upper_bound
  end

  # Compress a file
  def compress(input, quality = 80, output = nil)
    return compress_jpg(input, quality, output) if jpg?(input)
    return compress_png(input, quality, output) if png?(input)
  end

  # Try to guess if a file is already compressed
  def compressed?(input)
    quality(input) <= 85
  end

  # Try to get the current quality compression of the file
  # This is highly dependent of the encoder, and the same value won't mean the
  # same for different encoders
  def quality(input)
    `identify -format '%Q' #{input.shellescape}`.to_i
  end

  # Compress to the most aggressive quality, while still keeping a similar image
  # Note: This might yield inconsistent results as its based on an arbitrary
  # range (defined by dssim_lower_bound and dssim_upper_bound) that we
  # empirically defined as yielding "good enough" results. This might not work
  # for all kind of images.
  # A more thorough way would be to force a specific size threshold and pick the
  # compression that gives the lowest dssim score for this size.
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def compress_best_dssim(input)
    # Stop if file already compressed
    if compressed?(input)
      yield(false) if block_given?
      return input
    end

    previous_quality = nil
    quality = 120
    step = 80

    extname = File.extname(input)
    compressed_path = nil
    direction = :down

    loop do
      # Binary search type of stepping
      step = (step / 2).to_i
      previous_quality = quality
      quality -= step if direction == :down
      quality += step if direction == :up

      # Stop if we start going into an endless loop
      break if quality == previous_quality

      # Failsafe in case we try to compress above 100
      break if quality > 100

      # yield to the outer block to display the current tested quality
      yield(quality) if block_given?

      # Create a compressed file on disk (removing previous unused)
      FileUtils.rm(compressed_path) unless compressed_path.nil?
      compressed_path = input.gsub(
        /#{extname}$/,
        ".#{quality}#{extname}"
      )
      compressed = compress(input, quality, compressed_path)
      score = dssim(input, compressed)
      # ap "#{quality} => #{score}"

      break if score >= dssim_lower_bound && score <= dssim_upper_bound

      # Change direction if going too far
      direction = :up if direction == :down && score > dssim_upper_bound
      direction = :down if direction == :up && score < dssim_lower_bound
    end

    FileUtils.mv(compressed_path, input, force: true)
    input
  end
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
end
