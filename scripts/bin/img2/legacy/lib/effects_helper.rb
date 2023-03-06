# Image color effect transformation methods
module EffectsHelper
  # Return the number of colors of an image
  def palette_size(input)
    `identify -format %k #{input.shellescape}`.to_i
  end

  # Convert an image to grayscale
  def grayscale(input)
    options = [
      '-colorspace Gray',
      input.shellescape
    ]
    command = "mogrify #{options.join(' ')}"
    `#{command}`
  end

  # Is an image grayscale?
  def grayscale?(input)
    # By testing the average saturation of the image we can guess if it's
    # grayscale (then the saturation is 0)
    # Source: http://www.imagemagick.org/discourse-server/viewtopic.php?t=19580
    options = [
      input.shellescape,
      '-colorspace HSL',
      '-channel g',
      '-separate +channel',
      '-format "%[fx:mean]"',
      'info:'
    ]
    raw = `convert #{options.join(' ')}`.chomp.to_f
    raw.zero?
  end
end
