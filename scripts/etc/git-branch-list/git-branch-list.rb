# encoding : utf-8
# Display the list of current branches, colored according to git flow.


class GitBranchList

	def initialize(*args)
    @args = args;
    @colors = {
      :bugfix => 203,
      :develop => 184,
      :feature => 202,
      :fix => 203,
      :gh_pages => 24,
      :master => 69,
      :perf => 141,
      :release => 171,
      :remotes => 160,
      :review => 28,
      :test => 136
    }
    @hash_color = 67
	end

  # Wrap a text in color codes
  def colorize(text, color)
    color = "%03d" % color
    return "[38;5;#{color}m#{text}[00m"
  end

  def colorize_pattern(line, pattern, color)
    line.gsub(pattern) do |match|
      colorize(match, color)
    end
  end

  def colorize_hash(line)
    colorize_pattern(line, /([a-f0-9]{7})/, @hash_color)
  end

  def colorize_specific_branches(line) 
    @colors.each do |color|
      branch_name = color[0]
      branch_color = color[1]

      line = colorize_pattern(line, /( #{branch_name} )/, branch_color)
      line = colorize_pattern(line, /( #{branch_name}$)/, branch_color)
      line = colorize_pattern(line, /('#{branch_name}')/, branch_color)
      line = colorize_pattern(line, /( #{branch_name}\/(.*) )/, branch_color)
    end
    return line
  end

  def colorize_default_branches(line)
    colorize_pattern(line, /^( |\*) (.*) /, @colors[:feature])
  end

  def run
    output = %x[git branch --verbose #{@args.join(' ')}].split("\n")

    output.each do |line|
      line = colorize_hash(line)
      line = colorize_specific_branches(line)
      line = colorize_default_branches(line)
      puts line
    end
  end
end

