module AptGetHelper
  # TODO: installed? retourne true même si le package a été désinstallé
  @@colors = {
    error: 160,
    package: 141,
    version: 241,
    success: 35
  }

  # Loading all information on startup
  @@installed_packages = {}
  `dpkg -l | awk '{print $1,$2,$3}'`.split("\n").each do |package|
    type, name, version = package.split(' ')
    # Keep only packages marked as installed
    next unless type == 'ii'
    @@installed_packages[name] = version
  end

  def colorize(text, color)
    color = '%03d' % @@colors[color]
    "[38;5;#{color}m#{text}[00m"
  end

  def longest_by_type(list, type)
    ordered = list.map { |obj| obj[type] }.group_by(&:size)
    return nil if ordered.size == 0
    ordered.max.last[0]
  end

  def installed?(package)
    @@installed_packages.key?(package)
  end

  def install(package)
    exec "sudo apt-get install -y #{package}"
  end

  def get_version(package)
    return nil unless installed? package
    @@installed_packages[package]
  end
end
