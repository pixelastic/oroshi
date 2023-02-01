require 'spec_helper'

describe(CommandHelper) do
  let(:instance) { Class.new { include CommandHelper }.new }

  describe 'command_success?' do
    it 'should return true if command works' do
      # Given

      # When
      actual = instance.command_success?('true')

      # Then
      expect(actual).to eq true
    end

    it 'should return false if command fails' do
      # Given

      # When
      actual = instance.command_success?('false')

      # Then
      expect(actual).to eq false
    end

    it 'should return false if no command is passed' do
      # Given

      # When
      actual = instance.command_success?('')

      # Then
      expect(actual).to eq false
    end
  end

  describe 'command_stdout' do
    it 'should return what is output on stdout' do
      # Given

      # When
      actual = instance.command_stdout('echo "foo"')

      # Then
      expect(actual).to eq 'foo'
    end

    it 'should return an empty string if nothing is printed' do
      # Given

      # When
      actual = instance.command_stdout('true')

      # Then
      expect(actual).to eq ''
    end

    it 'should return an empty string if no command is executed' do
      # Given

      # When
      actual = instance.command_stdout('')

      # Then
      expect(actual).to eq ''
    end
  end
end
