# Output-related methods
module OutputHelper
  def display_usage
    puts 'Usage:'
    puts @usage
    puts ''
    puts @documentation
    exit 1
  end

  def notify(message)
    `notify-send "#{message}"`
  end
end
