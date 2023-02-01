# rubocop:disable Metrics/BlockLength
require 'spec_helper'

describe(GitCommitHelper) do
  let(:test_instance) { Class.new { include GitHelper }.new }

  after(:each) do |example|
    delete_directory(example)
  end

  describe 'current_commit' do
    it 'should return false in an empty directory' do
      # Given
      create_directory

      # When
      actual = test_instance.current_commit

      # Then
      expect(actual).to eq false
    end

    it 'should return nil in a new repo' do
      # Given
      create_repository

      # When
      actual = test_instance.current_commit

      # Then
      expect(actual).to eq nil
    end

    it 'should return a short md5 hash' do
      # Given
      create_repository
      add_commit

      # When
      actual = test_instance.current_commit

      # Then
      expect(actual).to match(/^[a-f0-9]{7}$/)
    end
  end

  describe 'commit?' do
    it 'should return false if commit not in the log' do
      # Given
      create_repository

      # When
      actual = test_instance.commit?('random')

      # Then
      expect(actual).to eq false
    end

    it 'should return true if commit in the log' do
      # Given
      create_repository
      add_commit

      # When
      current_commit = test_instance.current_commit
      actual = test_instance.commit?(current_commit)

      # Then
      expect(actual).to eq true
    end
  end

  describe 'commit_info' do
    it 'should return nil if no such commit' do
      # Given
      create_repository

      # When
      actual = test_instance.commit_info('random')

      # Then
      expect(actual).to eq nil
    end

    it 'should return a hash containing info about the commit' do
      # Given
      create_repository
      create_file('foo.txt')
      test_instance.stage_file('foo.txt')
      test_instance.create_commit("Subject\n\nBody")

      # When
      hash = test_instance.current_commit
      actual = test_instance.commit_info(hash)

      # Then
      expect(actual[:sha]).to eq hash
      expect(actual[:subject]).to eq 'Subject'
      expect(actual[:body]).to eq 'Body'
      expect(actual).to have_key(:author)
      expect(actual[:date]).to be_instance_of(Date)
    end
  end

  describe 'create_commit' do
    it 'should create a new commit' do
      # Given
      create_repository
      create_file('foo.txt')
      test_instance.stage_file('foo.txt')

      # When
      test_instance.create_commit('New commit')
      hash = test_instance.current_commit

      # Then
      expect(hash).not_to eq nil
    end

    it 'should set the specified message' do
      # Given
      create_repository
      create_file('foo.txt')
      test_instance.stage_file('foo.txt')
      test_instance.create_commit('foo')

      # When
      hash = test_instance.current_commit
      actual = test_instance.commit_info(hash)

      # Then
      expect(actual[:subject]).to eq 'foo'
    end
  end
end
# rubocop:enable Metrics/BlockLength
