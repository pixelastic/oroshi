require 'spec_helper'

describe(EffectsHelper) do
  let(:t) { Class.new { include ImageHelper }.new }
  let(:png) { fixture('png/dices.png') }
  let(:jpg) { fixture('jpg/game.jpg') }
  let(:gif) { fixture('gif/dices.gif') }
  let(:grayscale_jpg) { fixture('jpg/game-grayscale.jpg') }
  let(:grayscale_png) { fixture('png/tomb-grayscale.png') }
  let(:grayscale_gif) { fixture('gif/grayscale.gif') }

  describe 'palette_size' do
    it 'should return the number of colors of the image' do
      # Given
      input = png

      # When
      actual = t.palette_size(input)

      # Then
      expect(actual).to eq 7770
    end
  end

  describe 'grayscale?' do
    it 'should return true for grayscale jpg' do
      # Given
      input = grayscale_jpg

      # When
      actual = t.grayscale?(input)

      # Then
      expect(actual).to eq true
    end

    it 'should return false for colored jpg' do
      # Given
      input = jpg

      # When
      actual = t.grayscale?(input)

      # Then
      expect(actual).to eq false
    end

    it 'should return true for grayscale png' do
      # Given
      input = grayscale_png

      # When
      actual = t.grayscale?(input)

      # Then
      expect(actual).to eq true
    end

    it 'should return false for colored png' do
      # Given
      input = png

      # When
      actual = t.grayscale?(input)

      # Then
      expect(actual).to eq false
    end

    it 'should return true for grayscale gif' do
      # Given
      input = grayscale_gif

      # When
      actual = t.grayscale?(input)

      # Then
      expect(actual).to eq true
    end

    it 'should return false for colored gif' do
      # Given
      input = gif

      # When
      actual = t.grayscale?(input)

      # Then
      expect(actual).to eq false
    end
  end

  describe 'grayscale' do
    it 'should convert a png to grayscale' do
      # Given
      input = copy(png)

      # When
      t.grayscale(input)
      actual = t.grayscale?(input)

      # Then
      expect(actual).to eq true
    end

    it 'should convert a jpg to grayscale' do
      # Given
      input = copy(jpg)

      # When
      t.grayscale(input)
      actual = t.grayscale?(input)

      # Then
      expect(actual).to eq true
    end

    it 'should convert a gif to grayscale' do
      # Given
      input = copy(gif)

      # When
      t.grayscale(input)
      actual = t.grayscale?(input)

      # Then
      expect(actual).to eq true
    end
  end
end
