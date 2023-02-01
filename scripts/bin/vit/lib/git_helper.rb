require 'English'
require 'fileutils'
require 'open3'
require 'shellwords'
require_relative './command_helper'
require_relative './color_helper'
require_relative './dependency_helper'
require_relative './git_argument_helper'
require_relative './git_branch_helper'
require_relative './git_commit_helper'
require_relative './git_config_helper'
require_relative './git_file_helper'
require_relative './git_push_helper'
require_relative './git_remote_helper'
require_relative './git_repository_helper'
require_relative './git_tag_helper'

# Allow access to current git repository state
module GitHelper
  include CommandHelper
  include ColorHelper
  include DependencyHelper
  include GitArgumentHelper
  include GitBranchHelper
  include GitCommitHelper
  include GitConfigHelper
  include GitFileHelper
  include GitPushHelper
  include GitRemoteHelper
  include GitRepositoryHelper
  include GitTagHelper

  # Return only --flags
  def get_flag_args(args)
    flags = []
    args.each do |arg|
      flags << arg if arg =~ /^-/
    end
    flags
  end

  # Return only non --flags
  def get_real_args(args)
    real_args = []
    args.each do |arg|
      real_args << arg if arg !~ /^-/
    end
    replace_short_aliases real_args
  end

  def replace_short_aliases(elements)
    elements.map do |element|
      next 'develop' if element == 'd'
      next 'gh-pages' if element == 'g'
      next 'heroku' if element == 'h'
      next 'master' if element == 'm'
      next 'origin' if element == 'o'
      next 'release' if element == 'r'
      next 'upstream' if element == 'u'

      element
    end
  end

  def push_pull_indicator(branch_name)
    return ' ' if branch_gone?(branch_name)

    code = `git-branch-push-status #{branch_name}`.strip
    return ' ' if code == 'ahead'
    return ' ' if code == 'behind'
    return ' ' if code == 'diverged'
    return ' ' if code == 'never_pushed'
  end

  def longest_by_type(list, type)
    ordered = list.map { |obj| obj[type] }.group_by(&:size)
    ordered.max.last[0]
  end

  def submodule?(path)
    system("git-is-submodule #{path.shellescape}")
  end

  def current_tags
    tags = `git tag-current-all`.strip.split("\n")
    tags << current_tag
    tags.uniq
  end

  def closer_commit(commit_a, commit_b)
    `git-commit-closer #{commit_a} #{commit_b}`.strip
  end

  def remote_owner(remote)
    `git-remote-owner #{remote}`.strip
  end

  def branch_gone?(name)
    system("git branch-gone #{name}")
  end

  def never_pushed?
    code = `git branch-remote-status`.strip
    code == 'never_pushed'
  end

  # Pad every cell of a two-dimensionnal array so they are all the same length
  def pad_two_dimensionnal_array(array)
    column_count = array[0].length
    longests = Array.new(column_count, 0)
    array.each do |line|
      line.each_with_index do |cell, column|
        cell = '' if cell.nil?
        length = cell.size
        longest = longests[column]
        longests[column] = length if length > longest
      end
    end

    padded_array = array.map do |line|
      line.map.with_index do |cell, index|
        cell = '' if cell.nil?
        cell.ljust(longests[index])
      end
    end
    padded_array
  end
end
