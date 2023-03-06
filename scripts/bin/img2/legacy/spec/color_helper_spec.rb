require 'spec_helper'

describe(ColorHelper) do
  let(:t) { Class.new { include ImageHelper }.new }
  let(:jpg) { fixture('jpg/game.jpg') }
  let(:blue) { fixture('jpg/game-blue.jpg') }
  let(:dark) { fixture('jpg/game-dark.jpg') }

  describe 'rgb2hex' do
    it 'should convert an rgb value to an hex code' do
      # Given
      input = 'rgb(0,174,255)'

      # When
      actual = t.rgb2hex(input)

      # Then
      expect(actual).to eq '#00AEFF'
    end

    it 'should accept spaces in the rgb value' do
      # Given
      input = 'rgb(0, 174, 255)'

      # When
      actual = t.rgb2hex(input)

      # Then
      expect(actual).to eq '#00AEFF'
    end

    it 'should accept srgb values (coming from convert)' do
      # Given
      input = 'srgb(0, 174, 255)'

      # When
      actual = t.rgb2hex(input)

      # Then
      expect(actual).to eq '#00AEFF'
    end

    it 'should accept rgba values' do
      # Given
      input = 'rgba(0, 174, 255, 5)'

      # When
      actual = t.rgb2hex(input)

      # Then
      expect(actual).to eq '#00AEFF'
    end
  end

  describe 'maincolor' do
    it 'should return the main color of the image' do
      # Given
      input = blue

      # When
      actual = t.maincolor(input)

      # Then
      expect(actual).to eq '#28739B'
    end
  end

  describe 'tint' do
    it 'should tint a file with the specified color' do
      # Given
      input = copy(jpg)

      # When
      actual = t.tint(input, '#00AEFF')

      # Then
      expect(t.similar?(actual, blue)).to eq true
    end

    it 'should accept hexadecimal without the hash' do
      # Given
      input = copy(jpg)

      # When
      actual = t.tint(input, '00AEFF')

      # Then
      expect(t.similar?(actual, blue)).to eq true
    end
  end

  describe 'darken' do
    it 'should darken a file' do
      # Given
      input = copy(jpg)

      # When
      actual = t.darken(input)

      # Then
      expect(t.similar?(actual, dark)).to eq true
    end
  end
end
