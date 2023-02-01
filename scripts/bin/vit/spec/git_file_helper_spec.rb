# rubocop:disable Metrics/BlockLength
require 'spec_helper'

describe(GitFileHelper) do
  let(:test_instance) { Class.new { include GitHelper }.new }

  after(:each) do |example|
    delete_directory(example)
  end

  describe 'file_staged?' do
    it 'should return false for unstaged files' do
      # Given
      create_repository
      file = File.join(@repo_path, 'foo.txt')
      create_file(file)

      # When
      actual = test_instance.file_staged?(file)

      # Then
      expect(actual).to eq false
    end

    it 'should return true for staged files' do
      # Given
      create_repository
      file = File.join(@repo_path, 'foo.txt')
      create_file(file)

      # When
      test_instance.stage_file(file)
      actual = test_instance.file_staged?(file)

      # Then
      expect(actual).to eq true
    end
  end

  describe 'stage_file' do
    it 'should set the file as staged' do
      # Given
      create_repository
      file = File.join(@repo_path, 'foo.txt')
      create_file(file)

      # When
      test_instance.stage_file(file)
      actual = test_instance.file_staged?(file)

      # Then
      expect(actual).to eq true
    end
  end

  describe 'stage_files' do
    it 'should accept several files at once' do
      # Given
      create_repository
      file1 = File.join(@repo_path, 'foo.txt')
      file2 = File.join(@repo_path, 'bar.txt')
      create_file(file1)
      create_file(file2)

      # When
      test_instance.stage_files(file1, file2)
      actual1 = test_instance.file_staged?(file1)
      actual2 = test_instance.file_staged?(file2)

      # Then
      expect(actual1).to eq true
      expect(actual2).to eq true
    end
  end

  describe 'stage_all' do
    it 'should stage all the modified and new files' do
      # Given
      create_repository
      file1 = File.join(@repo_path, 'foo.txt')
      file2 = File.join(@repo_path, 'bar.txt')
      create_file(file1)
      create_file(file2)

      # When
      test_instance.stage_all
      actual1 = test_instance.file_staged?(file1)
      actual2 = test_instance.file_staged?(file2)

      # Then
      expect(actual1).to eq true
      expect(actual2).to eq true
    end
  end

  describe 'unstage_file' do
    it 'should unstage a file' do
      # Given
      create_repository
      file = File.join(@repo_path, 'foo.txt')
      create_file(file)

      # When
      test_instance.stage_file(file)
      test_instance.unstage_file(file)
      actual = test_instance.file_staged?(file)

      # Then
      expect(actual).to eq false
    end
  end

  describe 'unstage_files' do
    it 'should unstage several files at once' do
      # Given
      create_repository
      file1 = File.join(@repo_path, 'foo.txt')
      file2 = File.join(@repo_path, 'bar.txt')
      create_file(file1)
      create_file(file2)

      # When
      test_instance.stage_files(file1, file2)
      test_instance.unstage_files(file1, file2)
      actual1 = test_instance.file_staged?(file1)
      actual2 = test_instance.file_staged?(file2)

      # Then
      expect(actual1).to eq false
      expect(actual2).to eq false
    end
  end

  describe 'unstage_all' do
    it 'should unstage all the staged files' do
      # Given
      create_repository
      file1 = File.join(@repo_path, 'foo.txt')
      file2 = File.join(@repo_path, 'bar.txt')
      create_file(file1)
      create_file(file2)

      # When
      test_instance.stage_all
      test_instance.unstage_all
      actual1 = test_instance.file_staged?(file1)
      actual2 = test_instance.file_staged?(file2)

      # Then
      expect(actual1).to eq false
      expect(actual2).to eq false
    end
  end
end
# rubocop:enable Metrics/BlockLength
