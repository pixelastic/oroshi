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
