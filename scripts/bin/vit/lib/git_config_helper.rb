require_relative './command_helper'

# Config-related methods
module GitConfigHelper
  include CommandHelper

  def get_config(name)
    command = "git config --get #{name}"
    output = command_stdout(command)
    return nil if output.empty?

    output
  end

  def set_config(name, value)
    return false if name['.'].nil?

    command = "git config #{name} '#{value}'"
    command_success?(command)
  end
end
