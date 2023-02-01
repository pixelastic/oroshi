require 'spec_helper'

describe(GitConfigHelper) do
  let(:test_instance) { Class.new { include GitHelper }.new }

  after(:each) do |example|
    delete_directory(example)
  end

  describe 'get_config' do
    it 'should return the value of the specified config' do
      # Given
      create_repository
      set_config('foo.bar', 'baz')

      # When
      actual = test_instance.get_config('foo.bar')

      # Then
      expect(actual).to eq 'baz'
    end

    it 'should return nil if no config exists for this value' do
      # Given
      create_repository

      # When
      actual = test_instance.get_config('foo.bar')

      # Then
      expect(actual).to eq nil
    end
  end

  describe 'set_config' do
    it 'should not allow config set on first level' do
      # Given
      create_repository

      # When
      actual = test_instance.set_config('foo', 'bar')

      # Then
      expect(actual).to eq false
    end

    it 'should set the config value to the key specified' do
      # Given
      create_repository

      # When
      test_instance.set_config('foo.bar', 'baz')
      actual = test_instance.get_config('foo.bar')

      # Then
      expect(actual).to eq 'baz'
    end

    it 'should allow to override an existing value' do
      # Given
      create_repository

      # When
      test_instance.set_config('foo.bar', 'baz')
      test_instance.set_config('foo.bar', 'foo')
      actual = test_instance.get_config('foo.bar')

      # Then
      expect(actual).to eq 'foo'
    end
  end
end
