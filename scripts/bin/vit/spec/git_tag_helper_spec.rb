require 'spec_helper'

describe(GitTagHelper) do
  let(:test_instance) { Class.new { include GitHelper }.new }

  after(:each) do |example|
    delete_directory(example)
  end

  describe 'tag?' do
    it 'returns true if the tag exists' do
      # Given
      create_repository
      create_tag 'foo'

      # When
      actual = test_instance.tag? 'foo'

      # Then
      expect(actual).to eq true
    end

    it 'returns false if the tag does not exist' do
      # Given
      create_repository

      # When
      actual = test_instance.tag? 'do_not_exist'

      # Then
      expect(actual).to eq false
    end

    it 'returns false if only partial match' do
      # Given
      create_repository
      create_tag 'foobar'

      # When
      actual = test_instance.tag? 'foo'

      # Then
      expect(actual).to eq false
    end
  end

  describe 'current_tags' do
    it 'return the name of the tag on the current commit if any' do
      # Given
      create_repository
      create_tag 'foo'

      # When
      actual = test_instance.current_tag

      # Then
      expect(actual).to eq 'foo'
    end

    it 'returns nil if no tag set' do
      # Given
      create_repository

      # When
      actual = test_instance.current_tag

      # Then
      expect(actual).to eq nil
    end

    it 'returns the name of the closest tag' do
      # Given
      create_repository
      create_tag 'foo'
      add_commit

      # When
      actual = test_instance.current_tag

      # Then
      expect(actual).to eq 'foo'
    end
  end
end
