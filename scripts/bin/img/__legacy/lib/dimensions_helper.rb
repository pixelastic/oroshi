# Dimensions related methods
module DimensionsHelper
  # Returns the width of the input
  def width(input)
    raw = `exiftool -ImageWidth #{input.shellescape}`
    raw.split(':')[-1].to_i
  end

  # Returns the height of the input
  def height(input)
    raw = `exiftool -ImageHeight #{input.shellescape}`
    raw.split(':')[-1].to_i
  end

  # Resize the specified input
  def resize(input, dimensions, bypass_ratio: false, allow_increase: false)
    split = dimensions.to_s.split('x').map(&:to_i)

    # Stop if it would increase the dimensions
    unless allow_increase
      input_width = width(input)
      input_height = height(input)
      split.each do |dimension|
        return input if dimension > input_width && dimension > input_height
      end
    end

    # Bypass ratio in force mode
    if bypass_ratio
      split = split.map { |dimension| "#{dimension}!" }
      dimensions = split.join('x')
    end

    if gif?(input)
      dimensions = dimensions.delete('!')
      return resize_gif(input, dimensions)
    end

    options = [
      "-resize #{dimensions}"
    ]
    output = input
    `convert #{input.shellescape} #{options.join(' ')} #{output.shellescape}`
  end
end
