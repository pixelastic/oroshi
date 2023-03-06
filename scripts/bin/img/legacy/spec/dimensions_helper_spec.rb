require 'spec_helper'

describe(DimensionsHelper) do
  let(:test_instance) { Class.new { include ImageHelper }.new }
  let(:jpg) { fixture('jpg/game.jpg') }
  let(:gif) { fixture('gif/still.gif') }
  let(:jpg_100_50) { fixture('jpg/100x50.jpg') }
  let(:gif_100_50) { fixture('gif/100x50.gif') }

  describe 'width' do
    it 'should return the width of a JPG' do
      # Given
      input = jpg_100_50

      # When
      actual = test_instance.width(input)

      # Then
      expect(actual).to eq 100
    end

    it 'should return the width of a GIF' do
      # Given
      input = gif_100_50

      # When
      actual = test_instance.width(input)

      # Then
      expect(actual).to eq 100
    end
  end

  describe 'height' do
    it 'should return the height of a JPG' do
      # Given
      input = jpg_100_50

      # When
      actual = test_instance.height(input)

      # Then
      expect(actual).to eq 50
    end

    it 'should return the height of a GIF' do
      # Given
      input = gif_100_50

      # When
      actual = test_instance.height(input)

      # Then
      expect(actual).to eq 50
    end
  end

  describe 'resize' do
    it 'should resize an input to the specified dimensions' do
      # Given
      input = copy(jpg)
      width = test_instance.width(input) / 2
      height = test_instance.height(input) / 2

      # When
      test_instance.resize(input, "#{width}x#{height}")

      # Then
      expect(test_instance.width(input)).to eq width
      expect(test_instance.height(input)).to eq height
    end

    it 'should resize a GIF to the specified dimensions' do
      # Given
      input = copy(gif)
      width = test_instance.width(input) / 2
      height = test_instance.height(input) / 2

      # When
      test_instance.resize(input, "#{width}x#{height}")

      # Then
      expect(test_instance.width(input)).to eq width
      expect(test_instance.height(input)).to eq height
    end

    it 'should resize the largest size if only one size given and keep ratio' do
      # Given
      input = copy(jpg)
      width = test_instance.width(input)
      height = test_instance.height(input)

      # When
      test_instance.resize(input, width / 2)
      output_width = test_instance.width(input)
      output_height = test_instance.height(input)

      # Then
      expect(output_width).to eq width / 2
      expect(output_height).to eq height / 2
    end

    it 'should keep ratio' do
      # Given
      input = copy(jpg)
      resize = '600x600'

      # When
      test_instance.resize(input, resize)
      output_width = test_instance.width(input)
      output_height = test_instance.height(input)

      # Then
      expect(output_width).to eq 600
      expect(output_height).to eq 338
    end

    it 'should bypass ratio if force option is passed' do
      # Given
      input = copy(jpg)
      resize = '600x600'

      # When
      test_instance.resize(input, resize, bypass_ratio: true)
      output_width = test_instance.width(input)
      output_height = test_instance.height(input)

      # Then
      expect(output_width).to eq 600
      expect(output_height).to eq 600
    end

    it 'should stop if it would increase the dimensions of the file' do
      # Given
      input = copy(jpg)
      input_width = test_instance.width(input)
      input_height = test_instance.height(input)
      resize = '1800'

      # When
      test_instance.resize(input, resize)
      output_width = test_instance.width(input)
      output_height = test_instance.height(input)

      # Then
      expect(output_width).to eq input_width
      expect(output_height).to eq input_height
    end

    it 'should bypass stop for dimensions if force option is passed' do
      # Given
      input = copy(jpg)
      resize = '1800'

      # When
      test_instance.resize(input, resize, allow_increase: true)
      output_width = test_instance.width(input)
      output_height = test_instance.height(input)

      # Then
      expect(output_width).to eq 1800
      expect(output_height).to eq 1013
    end

    it 'should resize based on percentage if % is passed' do
      # Given
      input = copy(jpg)
      width = test_instance.width(input)
      height = test_instance.height(input)

      # When
      test_instance.resize(input, '50%')
      output_width = test_instance.width(input)
      output_height = test_instance.height(input)

      # Then
      expect(output_width).to eq width / 2
      expect(output_height).to eq height / 2
    end
  end
end
