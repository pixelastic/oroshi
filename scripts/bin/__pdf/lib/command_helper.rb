require 'awesome_print'
require 'open3'

# Simplified access to shell commands
module CommandHelper
  # Returns true if the specified command exits with 0, false otherwise
  def command_success?(command)
    return false if command.empty?
    _, _, status = Open3.capture3(command)
    status.success?
  end

  # Returns what is output on stdout
  def command_stdout(command)
    return '' if command.empty?
    stdout, = Open3.capture3(command)
    stdout.strip
  end
end
