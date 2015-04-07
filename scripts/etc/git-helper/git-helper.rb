module GitHelper
  @@colors = {
    :branch => 202,
    :branch_bugfix => 203,
    :branch_develop => 184,
    :branch_feature => 202,
    :branch_fix => 203,
    :branch_gh_pages => 24,
    :branch_master => 69,
    :branch_perf => 141,
    :branch_release => 171,
    :branch_review => 28,
    :branch_test => 136,
    :hash => 67,
    :message => 250,
    :tag => 241
  }

  def color(type)
    return @@colors[type]
  end

  def branch_color(branch)
    color_symbol = ('branch_' + branch).to_sym
    return @@colors[color_symbol] if @@colors[color_symbol]
    return @@colors[:branch]
  end

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
      next "origin" if element == "o"
      next "upstream" if element == "u"
      next "master" if element == "m"
      next "develop" if element == "d"
      element
    end
  end

  def colorize(text, color)
    color = "%03d" % color
    return "[38;5;#{color}m#{text}[00m"
  end

  def current_branch
    %x[git branch-current].strip
  end

  def current_remote
    %x[git remote-current].strip
  end

  def current_tag
    %x[git tag-current].strip
  end

  def is_branch(name)
    system("git branch-exists #{name}")
  end

  def is_remote(name)
    system("git remote-exists #{name}")
  end

  def is_tag(name)
    system("git tag-exists #{name}")
  end
  
  def never_pushed?
    system("git branch-remote-status")
    return true if $?.exitstatus == 4
    return false
  end

  def guess_elements(*elements)
    output = {}

    # Guess element types
    elements.each do |element|
      output[:branch] = element if is_branch element
      output[:remote] = element if is_remote element
      output[:tag] = element if is_tag element
    end

    # Set current one as default
    output[:branch] = current_branch if !output[:branch]
    output[:remote] = current_remote if !output[:remote]
    output[:tag] = current_tag if !output[:tag]

    # If still no remote, we default to origin
    output[:remote] = "origin" if output[:remote] == ""

    return output
  end



end
