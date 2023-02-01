require_relative './command_helper'

# Branch-related methods
module GitBranchHelper
  include CommandHelper

  # Checks if the specified branch exists
  def branch?(name)
    command = 'git branch -l'
    list = command_stdout(command)
    tokens = list.split(' ')
    tokens.delete('*')
    tokens.include?(name)
  end

  # Returns the current branch name
  def current_branch
    command = 'git rev-parse --abbrev-ref HEAD'
    command_stdout(command)
  end

  # Creates a branch of the specified name
  def create_branch(branch)
    command = "git checkout --quiet -b #{branch}"
    command_success?(command)
  end

  # Returns the number of commits ahead/behind two branches are
  def branch_difference(branch_a, branch_b)
    command = "git rev-list --left-right --count #{branch_a}...#{branch_b}"
    result = command_stdout(command)
    behind, ahead = result.split("\t")
    {
      behind: behind.to_i,
      ahead: ahead.to_i
    }
  end

  def branch_date_ago(branch_name)
    command = "git show --pretty=format:'%cr' #{branch_name} | head -1"
    command_stdout(command)
  end

  def parse_raw_branch(input)
    # Splitting the regexp in more manageable parts
    regexp_prefix = /(?<prefix> |\*)/
    regexp_hash = /(?<hash>[a-f0-9]*{8})/
    regexp_branch = /(?<branch>[^ ]*)/
    regexp_optional_detached = /(?<optional_detached>\(HEAD detached at #{regexp_hash}\))?/
    regexp_remote_info = /(?<remote_info>\[.*\])?/
    regexp_message = /(?<message>.*)/

    regexp_array = [
      "^#{regexp_prefix} ",
      regexp_optional_detached,
      "#{regexp_branch} *",
      "#{regexp_hash} ",
      "#{regexp_remote_info} ?",
      regexp_message
    ]

    # Matching the line with the regexp
    regexp = /#{regexp_array.join('')}/
    matches = input.match(regexp)
    prefix = matches[:prefix]
    optional_detached = matches[:optional_detached]
    branch = matches[:branch]
    hash = matches[:hash]
    remote_info = matches[:remote_info]
    message = matches[:message]

    branch_name_locally = branch
    branch_is_current = (prefix == '*')

    # Default values
    branch_name_remotely = branch_name_locally
    remote_name = current_remote
    remote_is_gone = false

    # Detached head
    unless optional_detached.nil?
      branch_name_locally = 'HEAD'
      branch_name_remotely = nil
    end

    # Remote info
    unless remote_info.nil?
      # Potential values
      # [origin/master]
      # [origin/master: ahead 2]
      # [origin/new-branch: gone]
      # [ahead 1, behind 5]
      remote_regexp_array = [
        /^\[/,
        # Remote origin/name
        %r{((?<remote_name>.*)/(?<branch_name>[^:]*))?},
        /(: )?/,
        # ahead
        /(ahead (?<remote_ahead>[0-9]*))?/,
        /(, )?/,
        # behind
        /(behind (?<remote_behind>[0-9]*))?/,
        # gone
        /(: (?<remote_gone>gone))?/,
        /\]$/
      ]
      remote_regexp = /#{remote_regexp_array.join('')}/
      remote_matches = remote_info.match(remote_regexp)

      remote_name = remote_matches[:remote_name] || remote_name
      branch_name_remotely = remote_matches[:branch_name] || branch_name_remotely

      remote_ahead = remote_matches[:remote_ahead]
      remote_behind = remote_matches[:remote_behind]
      remote_is_gone = true unless remote_matches[:remote_gone].nil?
    end

    {
      raw: input,
      hash: hash,
      is_current: branch_is_current,
      name: branch_name_locally,
      message: message,

      remote_name: remote_name,
      remote_branch_name: branch_name_remotely,
      remote_ahead: remote_ahead,
      remote_behind: remote_behind,
      remote_is_gone: remote_is_gone
    }
  end
end
