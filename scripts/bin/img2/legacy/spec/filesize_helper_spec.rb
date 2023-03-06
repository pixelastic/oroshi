require 'spec_helper'

describe(FilesizeHelper) do
  let(:test_instance) { Class.new { include ImageHelper }.new }
  let(:jpg) { fixture('jpg/tomb.jpg') }
  let(:gif_smallest) { fixture('gif/handtinyblack.gif') }
  let(:non_existing_gif) { fixture('gif/non-existing.gif') }

  describe 'filesize' do
    it 'should return the filesize of a file' do
      # Given
      input = gif_smallest

      # When
      actual = test_instance.filesize(input)

      # Then
      expect(actual).to eq 26
    end

    it 'should return nil if file does not exist' do
      # Given
      input = non_existing_gif

      # When
      actual = test_instance.filesize(input)

      # Then
      expect(actual).to eq nil
    end
  end

  describe 'readable_filesize' do
    it 'should display a readable size' do
      # Given
      input = 1024

      # When
      actual = test_instance.readable_filesize(input)

      # Then
      expect(actual).to eq '1.00 KiB'
    end
  end
end
