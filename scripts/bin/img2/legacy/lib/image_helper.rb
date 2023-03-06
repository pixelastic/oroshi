require 'fileutils'
require 'awesome_print'
require 'filesize'
require 'shellwords'
require_relative './arguments_helper'
require_relative './color_helper'
require_relative './command_line_helper'
require_relative './dimensions_helper'
require_relative './effects_helper'
require_relative './filesize_helper'
require_relative './gif_helper'
require_relative './jpg_helper'
require_relative './output_helper'
require_relative './png_helper'
require_relative './quality_helper'
require_relative './screenshot_helper'
require_relative './tif_helper'
require_relative './webp_helper'

# Various image editing utilities
module ImageHelper
  include ArgumentsHelper
  include ColorHelper
  include CommandLineHelper
  include DimensionsHelper
  include EffectsHelper
  include FilesizeHelper
  include GifHelper
  include JpgHelper
  include OutputHelper
  include PngHelper
  include QualityHelper
  include ScreenshotHelper
  include TifHelper
  include WebpHelper

  def change_extension(input, extension)
    dirname = File.dirname(input)
    basename = File.basename(input, File.extname(input))
    File.join(dirname, "#{basename}.#{extension}")
  end

  # Convert the specified to the specified extension
  def convert(input, extension)
    output = change_extension(input, extension)
    `convert #{input.shellescape} #{output.shellescape}`
    output
  end
end
