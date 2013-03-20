# encoding : utf-8
require 'test/unit'
require "fileutils"
require_relative '../camera-extract'

class CameraExtractTest < Test::Unit::TestCase

	def setup
		@tmp_dir = '/tmp/camera-extract-tmp'
		@dcim_dir = File.join(@tmp_dir, 'DCIM')
		@output_dir = File.join(@tmp_dir, 'output')

		@fake_dir = File.join(@tmp_dir, 'nonexistent')

		@data_dir = File.join(File.dirname(__FILE__), 'data')
		FileUtils.cp_r(@data_dir, @tmp_dir)

		@camera_extract = CameraExtract.new(@dcim_dir)
	end

	def teardown
		FileUtils.rm_rf(@tmp_dir)
	end

	def test_initialize_input
		# Correct input dir assignment
		input_dir = @dcim_dir
		a = CameraExtract.new(input_dir)
		assert_equal(a.input, input_dir)

		# Non-existent input dir
		assert_raise CameraExtract::DirNotFoundError, "Input dir not found" do
			input_dir = @fake_dir
			CameraExtract.new(input_dir)
		end
	end

	def test_initialize_output
		# Correct output dir
		input_dir = @dcim_dir
		output_dir = @output_dir
		a = CameraExtract.new(input_dir, output_dir)
		assert_equal(a.input, input_dir)
		assert_equal(a.output, output_dir)
	end


	def test_get_extract_list
		result = @camera_extract.get_extract_list(@dcim_dir)
		expected = [
			File.join(@dcim_dir, 'a.jpg'),
			File.join(@dcim_dir, 'b.JPG'),
			File.join(@dcim_dir, 'subdir/c.jpg')
		]
		assert_equal(result, expected)
	end

end
