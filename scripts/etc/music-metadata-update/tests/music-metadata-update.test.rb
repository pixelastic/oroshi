# encoding : utf-8
require 'test/unit'
require_relative '../music-metadata-update'

class MusicMetadataUpdateTest < Test::Unit::TestCase

	def test_parse_line
		assert_equal(true, true)
		# develop = "  develop  46b1c50 Merge branch 'feature/zsh5.0' into develop"
		# selected, name, id, desc = GitBranchList::parse_line(develop)
		# assert_equal(false, selected)
		# assert_equal("develop", name)
		# assert_equal("46b1c50", id)
		# assert_equal("Merge branch 'feature/zsh5.0' into develop", desc)
	end


end
