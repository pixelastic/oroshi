# Screenshot-related methods
module ScreenshotHelper
  # Select part of the screen and return its coordinate
  def screenshot_coordinates
    command = 'slop -f "%x %y %w %h"'
    output = `#{command}`

    split = output.split(' ')
    {
      x: split[0].to_i,
      y: split[1].to_i,
      width: split[2].to_i,
      height: split[3].to_i
    }
  end
end
