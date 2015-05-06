module AptGetHelper
  # TODO: installed? retourne true même si le package a été désinstallé
  @@colors = {
    :error => 160,
    :package => 141,
    :version => 241,
    :success => 35
  }

  def color(type)
    return @@colors[type]
  end

  def colorize(text, color)
    color = "%03d" % @@colors[color]
    return "[38;5;#{color}m#{text}[00m"
  end

  def installed?(package)
    system("dpkg -s #{package} 2>/dev/null 1>/dev/null")
  end

  def install(package)
    exec "sudo apt-get install #{package}"
  end

  def get_version(package)
    return nil if !installed? package
    %x[dpkg -s #{package} | grep 'Version:'].chomp.gsub('Version: ', '')
  end

  # def install
  #   %x[sudo aptgit root].strip
  # end

end

