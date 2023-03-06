require 'spec_helper'

describe(ArgumentsHelper) do
  let(:test_instance) { Class.new { include ImageHelper }.new }
  let(:gif) { fixture('gif/still.gif') }
  let(:jpg) { fixture('jpg/game.jpg') }
  let(:png) { fixture('png/dices.png') }
  let(:txt) { fixture('misc/txt.txt') }
  let(:non_existing_gif) { fixture('gif/non-existing.gif') }

  describe 'image?' do
    it 'should return true for gif files' do
      # Given
      input = gif

      # When
      actual = test_instance.image?(input)

      # Then
      expect(actual).to eq true
    end

    it 'should return true for jpg files' do
      # Given
      input = jpg

      # When
      actual = test_instance.image?(input)

      # Then
      expect(actual).to eq true
    end

    it 'should return true for png files' do
      # Given
      input = png

      # When
      actual = test_instance.image?(input)

      # Then
      expect(actual).to eq true
    end

    it 'should return false for non-image files' do
      # Given
      input = txt

      # When
      actual = test_instance.image?(input)

      # Then
      expect(actual).to eq false
    end
  end

  describe 'validate_inputs' do
    it 'should only keep inputs of the specified extension' do
      # Given
      input = [gif, jpg]

      # When
      actual = test_instance.validate_inputs(input, 'gif')

      # Then
      expect(actual.size).to eq 1
      expect(actual[0]).to eq gif
    end

    it 'should accept strings or symbols' do
      # Given
      input = [gif, jpg]

      # When
      actual = test_instance.validate_inputs(input, :gif)

      # Then
      expect(actual.size).to eq 1
      expect(actual[0]).to eq gif
    end

    it 'should not keep non-existing files' do
      # Given
      input = [gif, non_existing_gif]

      # When
      actual = test_instance.validate_inputs(input, :gif)

      # Then
      expect(actual.size).to eq 1
      expect(actual[0]).to eq gif
    end

    it 'should allow filtering on several types' do
      # Given
      input = [gif, jpg, png]

      # When
      actual = test_instance.validate_inputs(input, 'gif,jpg')

      # Then
      expect(actual.size).to eq 2
      expect(actual).to include(gif)
      expect(actual).to include(jpg)
    end
  end
end
