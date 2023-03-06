# TIF-related methods
module TifHelper
  # Check if file is a tif
  def tif?(input)
    extname = File.extname(input)
    ['.tif', '.tiff'].include?(extname.downcase)
  end
end
