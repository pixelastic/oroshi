# encoding : utf-8
# Display the list of current branches, colored according to git flow.


class GitBranchList

	def initialize(*args)
		@input = args[0] || `git branch --verbose`
	end

	# Parse a branch line into 4 useful parts
	def self.parse_line(line)
		regexp = /^(\*|\s?) (\S+)\s*(\w+) (.*)/
		match = regexp.match(line)
		return [ match[1] == "*", match[2], match[3], match[4] ]
	end

	def to_s
		return @input
	end

end

puts GitBranchList.new
# output=`git branch --verbose`
# regexp-replace output '^..develop' '[38;5;184m  develop[00m'
# regexp-replace output '^..master' '[38;5;069m  master[00m'
#     # reset     "%{[00m%}"
#     # FG[$color]="%{[38;5;${color}m%}"
# 
# 	# gitFlowDevelop    "184" # develop branch
# 	# gitFlowMaster     "069" # master branch
# 	# gitFlowHotfix     "160" # hotfix branch
# 	# gitFlowRelease    "028" # release branch
# 	# gitFlowFeature    "202" # feature branch
# 	# gitFlowBugfix     "203" # bugfix branch
# echo $output
