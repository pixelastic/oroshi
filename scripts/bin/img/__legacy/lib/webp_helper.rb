# Webp-related methods
module WebpHelper
  # Check if file is a webp
  def webp?(input)
    File.extname(input).casecmp('.webp').zero?
  end
end
