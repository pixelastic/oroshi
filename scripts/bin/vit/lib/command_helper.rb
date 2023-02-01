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

  # Run a command in the background
  # Will create a lockfile while the process is running
  def run_in_background(command, lockfile)
    return if File.exist?(lockfile)
    full_command = "touch #{lockfile} && #{command} >/dev/null 2>&1; rm #{lockfile}"
    pid = Process.fork { system full_command }
    Process.detach(pid)
  end
end
