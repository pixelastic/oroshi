# Access colors by color name or linked named
module ColorHelper
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

  COLORS = colors.merge(
    branch: colors['orange'],
    branch_head: colors['red'],
    branch_gone: colors['gray'],
    branch_develop: colors['yellow'],
    branch_master: colors['blue'],
    hash: colors['indigo'],
    message: colors['gray'],
    remote: colors['yellow'],
    remote_origin: colors['orange'],
    remote_pixelastic: colors['green'],
    remote_upstream: colors['blue'],
    tag: colors['gray'],
    valid: colors['green'],
    date: colors['blue'],
    ahead: colors['green'],
    behind: colors['red']
  ).freeze

  def color(target)
    COLORS[target]
  end

  def branch_color(branch)
    return COLORS[:branch_head] if branch == 'HEAD'
    return COLORS[:branch_gone] if branch_gone?(branch)
    return nil if branch.nil?

    color_symbol = ('branch_' + branch.tr('-', '_')).to_sym
    return COLORS[color_symbol] if COLORS[color_symbol]

    COLORS[:branch]
  end

  def remote_color(remote)
    color_symbol = ('remote_' + remote).to_sym
    return COLORS[color_symbol] if COLORS[color_symbol]

    COLORS[:remote]
  end

  def colorize(text, color)
    return nil if color.nil?

    color = format('%03d', color)
    "[38;5;#{color}m#{text}[00m"
  end
end
