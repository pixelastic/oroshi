# encoding : utf-8
require 'test/unit'
require_relative '../mp3'

class Mp3Test < Test::Unit::TestCase

	def setup
		@data_dir = File.join(File.dirname(__FILE__), 'data')
		@hexagone = File.join(@data_dir, 'R', 'Renaud', '1975 - Amoureux de Paname', '07 - Hexagone.mp3')
	end

	def test_get_metadatas_from_filepath_normal
		mp3 = Mp3.new(@hexagone)
		
		assert_equal("Hexagone", mp3.filepath_title)
		assert_equal(7, mp3.filepath_index)
		assert_equal("Amoureux de Paname", mp3.filepath_album)
		assert_equal(1975, mp3.filepath_year)
		assert_equal("Renaud", mp3.filepath_artist)
	end

	def test_get_metadatas_from_tags_normal
		mp3 = Mp3.new(@hexagone)
		
		assert_equal("Hexagone", mp3.tags_title)
		assert_equal(7, mp3.tags_index)
		assert_equal("Amoureux de Paname", mp3.tags_album)
		assert_equal(1975, mp3.tags_year)
		assert_equal("Renaud", mp3.tags_artist)
	end


end

