module AptGetHelper
  # TODO: installed? retourne true même si le package a été désinstallé
  @@colors = {
    :error => 160,
    :package => 141,
    :version => 241,
    :success => 35
  }

  # Loading all information on startup
  @@installed_packages = {}
  %x[dpkg -l | awk '{print $2,$3}'].split("\n").each do |package|
    name, version = package.split(" ")
    @@installed_packages[name] = version
  end

  def colorize(text, color)
    color = "%03d" % @@colors[color]
    return "[38;5;#{color}m#{text}[00m"
  end

  def longest_by_type(list, type)
    ordered = list.map {|obj| obj[type] }.group_by(&:size)
    return nil if ordered.size == 0
    return ordered.max.last[0]
  end

  def is_installed?(package)
    @@installed_packages.has_key?(package)
  end

  def install(package)
    exec "sudo apt-get install #{package}"
  end

  def get_version(package)
    return nil if !is_installed? package
    @@installed_packages[package]
  end

  # def install
  #   %x[sudo aptgit root].strip
  # end

end

