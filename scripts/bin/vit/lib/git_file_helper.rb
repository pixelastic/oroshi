require_relative './command_helper'

# Files-related methods
module GitFileHelper
  include CommandHelper

  # Check if the specified file is currently staged
  def file_staged?(path)
    command = 'git diff --cached --name-only'
    output = command_stdout(command)
    prefix = repo_root
    output.each_line do |line|
      line.strip!
      return true if path == "#{prefix}/#{line}"
    end
    false
  end

  # Add the specified file to the staging area
  def stage_file(path)
    stage_files(path)
  end

  # Add the specified files to the staging area
  def stage_files(*files)
    command = "git add --all #{files.join(' ')}"
    command_success?(command)
  end

  # Add all modified and new files to the staging area
  def stage_all
    command = 'git add --all'
    command_success?(command)
  end

  # Remove the specified file from the staging area
  def unstage_file(path)
    unstage_files(path)
  end

  # Remove the specified files from the staging area
  def unstage_files(*files)
    command = "git reset #{files.join(' ')}"
    command_success?(command)
  end

  # Remove all files from the staging area
  def unstage_all
    command = 'git reset'
    command_success?(command)
  end

  # Has the file changed between two commit
  def file_changed(start_commit, end_commit, filepath)
    command = "git diff --name-only '#{start_commit}..#{end_commit}' -- #{filepath}"
    changed_file = `#{command}`.strip
    return !changed_file.empty?
  end
end
