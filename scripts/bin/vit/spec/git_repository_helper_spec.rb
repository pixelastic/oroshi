# rubocop:disable Metrics/BlockLength
require 'spec_helper'

describe(GitRepositoryHelper) do
  let(:test_instance) { Class.new { include GitHelper }.new }

  after(:each) do |example|
    delete_directory(example)
  end

  describe 'repository?' do
    it 'returns false when not in a git repository' do
      # Given
      create_directory

      # When
      actual = test_instance.repository?

      # Then
      expect(actual).to eq false
    end

    it 'returns true when in a git repository' do
      # Given
      create_repository

      # When
      actual = test_instance.repository?

      # Then
      expect(actual).to eq true
    end

    it 'returns false when given a non-git directory as input' do
      # Given
      create_directory
      move_out_of_directory

      # When
      actual = test_instance.repository?(@repo_path)

      # Then
      expect(actual).to eq false
    end

    it 'returns true when given a git directory as input' do
      # Given
      create_repository
      move_out_of_directory

      # When
      actual = test_instance.repository?(@repo_path)

      # Then
      expect(actual).to eq true
    end

    it 'returns false when given a non-existent directory as input' do
      # Given

      # When
      actual = test_instance.repository?('/i_do_not_exist')

      # Then
      expect(actual).to eq false
    end

    it 'returns false when given the special .git directory' do
      # Given
      create_repository

      # When
      actual = test_instance.repository?('./.git')

      # Then
      expect(actual).to eq false
    end

    it 'returns true when the repo name contains a .git' do
      # Given
      create_repository
      old_path = @repo_path
      @repo_path = "#{@repo_path}.git"
      FileUtils.mv(old_path, @repo_path)

      # When
      actual = test_instance.repository?(@repo_path)

      # Then
      expect(actual).to eq true
    end

    it 'returns false when in the special .git directory' do
      # Given
      create_repository
      Dir.chdir('./.git')

      # When
      actual = test_instance.repository?

      # Then
      expect(actual).to eq false
    end

    it 'returns false when given a special .git directory subdir' do
      # Given
      create_repository

      # When
      actual = test_instance.repository?('./.git/objects')

      # Then
      expect(actual).to eq false
    end

    it 'returns false when in a special .git directory subdir' do
      # Given
      create_repository
      Dir.chdir('./.git/objects')

      # When
      actual = test_instance.repository?

      # Then
      expect(actual).to eq false
    end
  end

  describe 'repo_root' do
    it 'should return the current path when in the root' do
      # Given
      create_repository

      # When
      actual = test_instance.repo_root

      # Then
      expect(actual).to eq @repo_path
    end

    it 'should return the root when in a subdirectory' do
      # Given
      create_repository
      create_and_move_to_subdirectory

      # When
      actual = test_instance.repo_root

      # Then
      expect(actual).to eq @repo_path
    end

    it 'should return nil if not in a repo' do
      # Given
      create_directory

      # When
      actual = test_instance.repo_root

      # Then
      expect(actual).to eq nil
    end

    it 'should return the path when given path to a repo' do
      # Given
      create_repository
      move_out_of_directory

      # When
      actual = test_instance.repo_root(@repo_path)

      # Then
      expect(actual).to eq @repo_path
    end

    it 'should return the root when given path a subdirectory of a repo' do
      # Given
      create_repository
      create_and_move_to_subdirectory
      move_out_of_directory

      # When
      actual = test_instance.repo_root(@repo_subdir_path)

      # Then
      expect(actual).to eq @repo_path
    end

    it 'should return nil when given the path to a normal directory' do
      # Given
      create_directory
      move_out_of_directory

      # When
      actual = test_instance.repo_root(@repo_path)

      # Then
      expect(actual).to eq nil
    end

    it 'should return the nil when in the special .git folder' do
      # Given
      create_repository
      Dir.chdir('./.git/objects')

      # When
      actual = test_instance.repo_root

      # Then
      expect(actual).to eq nil
    end
  end

  describe 'create_repo' do
    it 'creates a git repository in the current directory' do
      # Given
      create_directory

      # When
      test_instance.create_repo

      # Then
      expect(test_instance.repository?).to eq true
    end

    it 'creates a git repository in the specified directory' do
      # Given
      create_directory
      move_out_of_directory

      # When
      test_instance.create_repo(@repo_path)

      # Then
      expect(test_instance.repository?(@repo_path)).to eq true
    end

    it 'creates a repository even if the specified directory does not exist' do
      # Given
      create_directory
      move_out_of_directory
      subdir = File.join(@repo_path, 'subdir')

      # When
      test_instance.create_repo(subdir)

      # Then
      expect(test_instance.repository?(subdir)).to eq true
    end
  end
end
# rubocop:enable Metrics/BlockLength
