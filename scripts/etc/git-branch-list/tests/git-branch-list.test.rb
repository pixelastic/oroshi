# encoding : utf-8
require 'test/unit'
require_relative '../git-branch-list'

class GitBranchListTest < Test::Unit::TestCase

	def test_parse_line
		develop = "  develop  46b1c50 Merge branch 'feature/zsh5.0' into develop"
		selected, name, id, desc = GitBranchList::parse_line(develop)
		assert_equal(false, selected)
		assert_equal("develop", name)
		assert_equal("46b1c50", id)
		assert_equal("Merge branch 'feature/zsh5.0' into develop", desc)
	end

	def test_color_text
		output = GitBranchList::color_text('develop', 184)
		expected = "[38;5;184mdevelop[00m"
		assert_equal(expected, output)

		output = GitBranchList::color_text('master', 69)
		expected = "[38;5;069mmaster[00m"
		assert_equal(expected, output)
	end

	def test_color_branchname
		output = GitBranchList::color_branchname("  develop  46b1c50 Merge branch 'feature/zsh5.0' into develop")
		expected = "  [38;5;184mdevelop[00m  46b1c50 Merge branch 'feature/zsh5.0' into [38;5;184mdevelop[00m"
		assert_equal(expected, output)

		output = GitBranchList::color_branchname("  master  46b1c50 Another message")
		expected = "  [38;5;069mmaster[00m  46b1c50 Another message"
		assert_equal(expected, output)

		# output = GitBranchList::color_branchname("  feature/save-the-cheerleader  46b1c50 Save the world")
		# expected = "  [38;5;202mfeature/save-the-cheerleader[00m  46b1c50 Save the world"
		# assert_equal(expected, output)

	end

end
