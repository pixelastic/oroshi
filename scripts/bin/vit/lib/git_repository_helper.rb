require_relative './command_helper'

# Repository-related methods
module GitRepositoryHelper
  include CommandHelper

  # Returns the path to the repo root
  def repo_root(directory = nil)
    directory = File.expand_path('.') if directory.nil?
    return nil unless repository?(directory)

    previous_dir = File.expand_path('.')
    Dir.chdir(directory)
    output = command_stdout('git root')
    Dir.chdir(previous_dir)
    output
  end

  # Check if the directory is a git repository
  def repository?(directory = nil)
    command = 'git rev-parse'
    # expand_path might fail if we're in a directory that was deleted
    begin
      directory = File.expand_path('.') if directory.nil?
    rescue StandardError
      return false
    end

    # Directory does not exist, so can't be a git one
    return false unless File.exist?(directory)

    # Special .git directory can't be considered a repo
    split = directory.split('/')
    return false if split.include?('.git')

    # We temporarily change dir if one is specified
    previous_dir = File.expand_path('.')
    Dir.chdir(directory)
    success = command_success?(command)
    Dir.chdir(previous_dir)
    success
  end

  # Create a git repo on the specified filepath (default to current directory)
  def create_repo(directory = nil)
    current_dir = File.expand_path('.')
    directory = current_dir if directory.nil?
    FileUtils.mkdir_p(directory) unless File.exist?(directory)
    Dir.chdir(directory)

    command = 'git init'
    success = command_success?(command)

    Dir.chdir(current_dir)
    success
  end
end
