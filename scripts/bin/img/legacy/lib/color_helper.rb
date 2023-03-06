# Color related methods
module ColorHelper
  # Convert a rgb value into an hexadecimal one
  def rgb2hex(input)
    regex = /.*\((.*)\)/
    rgb = regex.match(input)[1]
    rgb = rgb.delete(' ').split(',')[0..2]
    hex = rgb.map { |x| format('%02x', x) }.join.upcase

    "##{hex}"
  end

  # Return the hexadecimal code of the main color of the image
  def maincolor(image)
    options = [
      image.shellescape,
      '-scale 1x1!',
      "-format '%[pixel:u]'",
      'info:-'
    ]
    command = "convert #{options.join(' ')}"
    raw = `#{command}`

    rgb2hex(raw)
  end

  # Tint a file to a given color
  def tint(input, color)
    color = "##{color}" unless color[0] == '#'
    options = [
      '-colorspace Gray',
      "-fill '#{color}'",
      '-tint 100',
      input.shellescape
    ]
    command = "mogrify #{options.join(' ')}"
    `#{command}`
    input
  end

  # Darken an image
  def darken(input)
    options = [
      '-brightness-contrast -10x0',
      input.shellescape
    ]
    command = "mogrify #{options.join(' ')}"
    `#{command}`
    input
  end
end
