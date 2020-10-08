# frozen_string_literal: true

# Shared module to access information about installed packages
module AptGetHelper
  COLORS = {
    package_uninstalled: 24,
    package_installed: 46,
    version_uninstalled: 27,
    version_installed: 96,
    version_mismatch: 36,

    error: 36,
    package: 23,
    version: 96,
    outdated: 35,
    success: 46
  }.freeze

  def colorize(text, color)
    color = format('%<color>03d', { color: COLORS[color] })
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
    command =  "apt-cache policy #{package} | grep --color=never 'Installed'"
    raw = `#{command}`.strip
    return nil if raw == ''

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
