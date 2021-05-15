# Helper methods used in the `docker-` scripts
module DockerHelper
  # Create an array of named colors
  orderedcolors = %w[gray red green yellow blue purple teal orange indigo pink]
  colors = {}
  orderedcolors.each_with_index do |color_prefix_name, color_prefix_index|
    10.times do |color_index|
      color_name = "#{color_prefix_name}#{color_index}"
      color_value = ((color_prefix_index + 2) * 10) + color_index
      colors[color_name] = color_value
    end
    colors[color_prefix_name] = colors["#{color_prefix_name}6"]
  end

  @@colors = {
    container: colors['yellow'],
    container_running: colors['green'],
    container_stopped: colors['red8'],
    hash: colors['indigo'],
    image: colors['yellow'],
    image_ubuntu: 202,
    ports: colors['pink'],
    tag: colors['orange']
  }

  # Return an array of all images
  def images
    `docker images --format '{{.Repository}}' | sort`.split("\n")
  end

  # Check if the specified image_name is already used
  def image?(image_name)
    image_name = image_name.split(':')[0] if image_name.include?(':')
    images.include?(image_name)
  end

  # Remove an image
  def image_remove(image_name)
    `docker rmi -f #{image_name}`
  end

  # Prune dangling images
  def prune_images
    dangling = `docker images -f "dangling=true" -q`
    dangling.lines do |id|
      `docker rmi --force #{id}`
    end
  end

  # Return an array of all containers
  def containers
    `docker-container-list-completion`.split("\n")
  end

  # Check if the specified container_name is already used
  def container?(container_name)
    containers.include?(container_name)
  end

  # Remove a container
  def container_remove(container_name)
    `docker rm --force #{container_name}`
  end

  def color(type)
    @@colors[type]
  end

  def image_color(image)
    color_symbol = ('image_' + image.tr('-', '_')).to_sym
    return @@colors[color_symbol] if @@colors[color_symbol]
    @@colors[:image]
  end

  def colorize(text, input_color)
    input_color = color(input_color) if input_color.is_a? Symbol
    input_color = format('%03d', input_color)
    "[38;5;#{input_color}m#{text}[00m"
  end

  def longest_by_type(list, type)
    ordered = list.map { |obj| obj[type] }.group_by(&:size)
    return nil if ordered.empty?
    ordered.max.last[0]
  end

end
