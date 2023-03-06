require 'spec_helper'

describe(JpgHelper) do
  let(:t) { Class.new { include ImageHelper }.new }
  let(:jpg) { fixture('jpg/game.jpg') }
  let(:jpeg) { fixture('jpg/game.jpeg') }
  let(:grayscale) { fixture('jpg/game-grayscale.jpg') }

  describe 'jpg?' do
    it 'returns true if file is a jpg' do
      # Given
      input = jpg

      # When
      actual = t.jpg?(input)

      # Then
      expect(actual).to eq true
    end

    it 'returns true if file is a jpeg' do
      # Given
      input = jpeg

      # When
      actual = t.jpg?(input)

      # Then
      expect(actual).to eq true
    end
  end

  describe 'compress_jpg' do
    it 'should compress JPG files into smaller files' do
      # Given
      input = copy(jpg)
      before = t.filesize(input)

      # When
      t.compress_jpg(input)
      after = t.filesize(input)

      # Then
      expect(after).to be < before
    end

    it 'should compress more when a smaller quality is given' do
      # Given
      input = copy(jpg)

      # When
      t.compress_jpg(input, 80)
      filesize80 = t.filesize(input)

      input = copy(jpg)
      t.compress_jpg(input, 20)
      filesize20 = t.filesize(input)

      # Then
      expect(filesize20).to be < filesize80
    end

    it 'should allow specifying an output file' do
      # Given
      input = copy(jpg)
      before = t.filesize(input)
      output_path = File.join(File.dirname(input), 'output.jpg')

      # When
      actual = t.compress_jpg(input, 80, output_path)
      after = t.filesize(actual)

      # Then
      expect(after).to be < before
    end
  end
end
