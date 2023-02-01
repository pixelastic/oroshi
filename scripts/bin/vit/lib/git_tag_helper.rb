require_relative './command_helper'

# Tag-related methods
module GitTagHelper
  include CommandHelper

  # Checks if the specified tag exists
  def tag?(name)
    command = "git tag -l #{name.shellescape}"
    output = command_stdout(command)
    output == name
  end

  # Returns the closest tag
  def current_tag
    command = 'git describe --tags --abbrev=0'
    tag = command_stdout(command)
    return nil if tag == ''

    tag
  end

  # Returns true if a specific commit is tagged
  def commit_tagged?(commit)
    commit = 'HEAD' if commit.nil?
    command = "git describe --exact-match #{commit}"
    command_success?(command)
  end
end
