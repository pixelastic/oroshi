# encoding : utf-8
# Display the list of current branches, colored according to git flow.


class GitBranchList
    @branch_colors = {
      :master => 69,
      :develop => 184,
      :bugfix => 203,
      :feature => 202,
      :review => 28,
      :remotes => 160
    }
    @hash_color = 67

  def self.color_branchname(txt)
    branches=/master|develop|bugfix|feature|review|remotes/
    suffix=/\/?[\w\/\-\.]*/

    # branch names
    txt.gsub!(/((#{branches})#{suffix})/) do |_|
      fullname, type = $1, $2
      color=@branch_colors[type.to_sym]
      self.color_text(fullname, color)
    end

    # commit hash
    txt.gsub!(/([a-f0-9]{7})/) do |hash|
      self.color_text(hash, @hash_color)
    end


    return txt
  end

  # Wrap a text in color codes
  def self.color_text(text, color)
    color = "%03d" % color
    return "[38;5;#{color}m#{text}[00m"
  end


end

