# Set of common methods to get informations about gems
module GemHelper
  @@colors = {
    error: 160,
    gem: 141,
    version: 241,
    success: 35
  }

  # Loading all information on startup
  @@installed_gems = {}
  `gem list`.split("\n").each do |gem|
    name, version = gem.chomp.match(/(.*) \((.*)\)$/).captures
    @@installed_gems[name] = version
  end

  def colorize(text, color)
    color = format('%03d', @@colors[color])
    "[38;5;#{color}m#{text}[00m"
  end

  def longest_by_type(list, type)
    ordered = list.map { |obj| obj[type] }.group_by(&:size)
    return nil if ordered.size == 0
    ordered.max.last[0]
  end

  def installed?(gem)
    @@installed_gems.key?(gem)
  end

  def install(gem)
    exec "gem install #{gem}"
  end

  def get_version(gem)
    return nil unless installed? gem
    @@installed_gems[gem]
  end
end
