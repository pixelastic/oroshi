# encoding : utf-8
# Display the list of current branches, colored according to git flow.


class GitBranchList
		@branch_colors = {
			:develop => 184,
			:master => 69,
			:hotfix => 160,
			:release => 28,
			:feature => 202,
			:bugfix => 203
		}

	def initialize(*args)
		@input = args[0] || `git branch --verbose`
	end

	def to_s
		return @input
	end

	# Parse a branch line into 4 useful parts
	def self.parse_line(line)
		regexp = /^(\*|\s?) (\S+)\s*(\w+) (.*)/
		match = regexp.match(line)
		return [ match[1] == "*", match[2], match[3], match[4] ]
	end

	def self.color_branchname(line)
		# Color main branches
		# line.gsub!(/develop/, self.color_text('develop', 184))
		# line.gsub!(/master/, self.color_text('master', 69))
		# line.gsub!(/(develop|master)/) do |foo|
		# 	name=$1
		# 	color=@branch_colors[name.to_sym]
		# 	self.color_text(name, color)
		# end

		line.gsub!(/((feature|develop|master)[\w\/\-\.]*)/) do |foo|
			fullname=$1
			prefix=$2
			color=@branch_colors[prefix.to_sym]
			self.color_text(fullname, color)
		end
		return line


	end

	# Wrap a text in color codes
	def self.color_text(text, color)
		color = "%03d" % color
		return "[38;5;#{color}m#{text}[00m"
	end


end

# puts GitBranchList.new
# output=`git branch --verbose`
# regexp-replace output '^..develop' '[38;5;184m  develop[00m'
# regexp-replace output '^..master' '[38;5;069m  master[00m'
#     # reset     "%{[00m%}"
#     # FG[$color]="%{[38;5;${color}m%}"
# 
# echo $output
