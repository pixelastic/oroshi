# Helper methods used in the `docker-` scripts
module DockerHelper
  @@colors = {
    container: 69,
    container_running: 35,
    container_stopped: 241,
    hash: 67,
    image: 136,
    image_ubuntu: 202,
    ports: 241,
    tag: 241
  }

  def color(type)
    @@colors[type]
  end

  def image_color(image)
    color_symbol = ('image_' + image.tr('-', '_')).to_sym
    return @@colors[color_symbol] if @@colors[color_symbol]
    @@colors[:image]
  end

  def colorize(text, color)
    color = format('%03d', color)
    "[38;5;#{color}m#{text}[00m"
  end

  def longest_by_type(list, type)
    ordered = list.map { |obj| obj[type] }.group_by(&:size)
    return nil if ordered.empty?
    ordered.max.last[0]
  end
end
