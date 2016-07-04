# Shared module to access information about installed packages
module AptGetHelper
  @@colors = {
    error: 160,
    package: 141,
    version: 241,
    outdated: 185,
    success: 35
  }

  def colorize(text, color)
    color = '%03d' % @@colors[color]
    "[38;5;#{color}m#{text}[00m"
  end

  def longest_by_type(list, type)
    ordered = list.map { |obj| obj[type] }.group_by(&:size)
    return nil if ordered.empty?
    ordered.max.last[0]
  end

  def installed?(package)
    !get_current_version(package).nil?
  end

  def install(package)
    exec "sudo apt-get install -y #{package}"
  end

  # Returns the current (installed) version of the package
  def get_current_version(package)
    raw = `apt-cache policy #{package} | grep 'Installed'`.strip
    version = raw.gsub('Installed: ', '')
    return nil if version == '(none)'
    version
  end

  # Returns the max available version
  def get_max_available_version(package)
    raw = `apt-cache policy #{package} | grep 'Candidate'`.strip
    raw.gsub('Candidate: ', '')
  end
end
