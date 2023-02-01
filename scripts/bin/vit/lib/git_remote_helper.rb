require_relative './command_helper'

# Remote-related methods
module GitRemoteHelper
  include CommandHelper

  # Checks if the specified remote exists
  def remote?(name)
    !get_config("remote.#{name}.url").nil?
  end

  # Return the name of the current remote
  def current_remote
    remote = get_config("branch.#{current_branch}.remote")
    return 'origin' if remote.nil?

    remote
  end

  # Set the current remote as the specified one
  def set_current_remote(remote, branch = nil)
    return false unless remote?(remote)

    branch = current_branch if branch.nil?
    return false if branch == 'HEAD'
    return false unless branch?(branch)
    return false if remote == current_remote

    set_config("branch.#{branch}.remote", remote)
  end

  # Create the specified remote with specified url
  def create_remote(name, url)
    return false if remote?(name)

    command = "git remote add '#{name}' '#{url}'"
    command_success?(command)
  end

  # Returns the url of a given remote
  def remote_url(name)
    return false unless remote?(name)

    get_config("remote.#{name}.url")
  end

  # Set the remote url
  def set_remote_url(remote, url)
    return false unless remote?(remote)

    command = "git remote set-url #{remote} '#{url}'"
    return false unless command_success?(command)

    # When setting url for origin, we manually also need to set the fetch
    if remote == 'origin' && get_config('remote.origin.fetch').nil?
      return set_config(
        'remote.origin.fetch',
        '+refs/heads/*:refs/remotes/origin/*'
      )
    end

    true
  end

  # Expand a shorthand username/reponame string to a github url
  def expand_short_github_url(input)
    "git@github.com:#{input}.git"
  end

  # Extract username and reponame form a GitHub url
  def extract_github_url(input)
    regex = %r{git@github.com:(.*)/(.*)\.git}
    matches = regex.match(input).captures
    {
      user: matches[0],
      repo: matches[1]
    }
  end
end
