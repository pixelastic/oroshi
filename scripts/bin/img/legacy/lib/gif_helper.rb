# GIF-related methods
module GifHelper
  # Check if file is a gif
  def gif?(input)
    File.extname(input).casecmp('.gif').zero?
  end

  # Returns true if input is an animated GIF
  def animated?(input)
    return false unless gif?(input)
    frames = `identify -format %n #{input.shellescape}`.to_i
    frames > 1
  end

  # Returns true if gif is animated with an infinite loop
  def looped?(input)
    return false unless gif?(input)
    raw = `exiftool #{input.shellescape} | grep 'Animation Iterations'`.strip
    raw.split(' : ')[1] == 'Infinite'
  end

  # Specific method to resize GIF
  def resize_gif(input, dimensions)
    gifsicle_options = [
      '--batch',
      "--resize #{dimensions}",
      '--colors 256',
      input.shellescape
    ]

    command = "gifsicle #{gifsicle_options.join(' ')} 2>/dev/null"

    `#{command}`
  end

  # Compress a GIF file
  def compress_gif(input)
    before = filesize(input)
    options = [
      '--batch',
      '-O3',
      '--colors 256',
      input.shellescape
    ]

    command = "gifsicle #{options.join(' ')} 2>/dev/null"
    `#{command}`

    after = filesize(input)

    display_compress(input, before, after)
  end

  # Set an infinite loop on an animated gif
  def make_loop(input)
    options = [
      '--batch',
      '--loopcount',
      input.shellescape
    ]
    command = "gifsicle #{options.join(' ')}"
    `#{command}`
  end

  # Make an animated gif loop only once
  def unloop(input)
    options = [
      '--batch',
      '--loopcount=0',
      input.shellescape
    ]
    command = "gifsicle #{options.join(' ')}"
    `#{command}`
  end

  # Return the speed of the animation
  def speed(input)
    return 0 unless animated?(input)
    options = [
      '-verbose',
      "#{input.shellescape}[0]",
      '| grep Delay'
    ]
    command = "identify #{options.join(' ')}"
    raw_result = `#{command}`.strip

    matches = /^Delay: ([0-9]*)x([0-9]*)/.match(raw_result)
    matches[1].to_i
  end

  # Change the speed of an animation
  def set_speed(input, speed)
    options = [
      "-delay #{speed}",
      input.shellescape
    ]

    command = "mogrify #{options.join(' ')}"
    `#{command}`
  end
end
