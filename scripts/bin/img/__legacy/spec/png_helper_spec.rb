require 'spec_helper'

describe(PngHelper) do
  let(:t) { Class.new { include ImageHelper }.new }
  let(:png) { fixture('png/dices.png') }
  let(:aasimar) { fixture('png/aasimar.png') }
  let(:grayscale) { fixture('png/tomb-grayscale.png') }

  describe 'png?' do
    it 'returns true if file is a png' do
      # Given
      input = png

      # When
      actual = t.png?(input)

      # Then
      expect(actual).to eq true
    end
  end

  describe 'compress_png' do
    it 'should compress png files into smaller files' do
      # Given
      input = copy(png)
      before = t.filesize(input)

      # When
      t.compress_png(input)
      after = t.filesize(input)

      # Then
      expect(after).to be < before
    end

    it 'should compress more when a smaller quality is given' do
      # Given
      input = copy(png)

      # When
      t.compress_png(input, 80)
      filesize80 = t.filesize(input)

      input = copy(png)
      t.compress_png(input, 20)
      filesize20 = t.filesize(input)

      # Then
      expect(filesize20).to be < filesize80
    end

    it 'should allow specifying an output file' do
      # Given
      input = copy(png)
      before = t.filesize(input)
      output_path = File.join(File.dirname(input), 'output.png')

      # When
      actual = t.compress_png(input, 80, output_path)
      after = t.filesize(actual)

      # Then
      expect(after).to be < before
    end
  end

  describe 'trim' do
    it 'should remove whitespace around the image' do
      # Given
      input = copy(aasimar)
      before_width = t.width(input)
      before_height = t.height(input)

      # When
      t.trim(input)
      after_width = t.width(input)
      after_height = t.height(input)

      # Then
      expect(before_width).to be > after_width
      expect(before_height).to be > after_height
    end
  end
end
