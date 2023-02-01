# rubocop:disable Metrics/BlockLength
require 'spec_helper'

describe(GitRemoteHelper) do
  let(:current) { Class.new { include GitHelper }.new }

  after(:each) do |example|
    delete_directory(example)
  end

  describe 'remote?' do
    it 'returns true if the remote exists' do
      # Given
      create_repository
      create_remote('foo')

      # When
      actual = current.remote? 'foo'

      # Then
      expect(actual).to eq true
    end

    it 'returns false if the remote does not exist' do
      # Given
      create_repository

      # When
      actual = current.remote? 'do_not_exist'

      # Then
      expect(actual).to eq false
    end
  end

  describe 'current_remote' do
    it 'returns the name of the current remote associated with the branch' do
      # Given
      create_repository
      create_branch_with_remote('develop', 'upstream')

      # When
      actual = current.current_remote

      # Then
      expect(actual).to eq 'upstream'
    end

    it 'returns origin if no remote specified' do
      # Given
      create_repository

      # When
      actual = current.current_remote

      # Then
      expect(actual).to eq 'origin'
    end
  end

  describe 'create_remote' do
    it 'should create a remote with the specified name' do
      # Given
      create_repository

      # When
      current.create_remote('foo', 'url')
      actual = current.remote?('foo')

      # Then
      expect(actual).to eq true
    end

    it 'should return false if trying to overide an existing remote' do
      # Given
      create_repository
      current.create_remote('foo', 'url')

      # When
      actual = current.create_remote('foo', 'url again')

      # Then
      expect(actual).to eq false
    end

    it 'should set the fetch option associated with the remote' do
      # Given
      create_repository
      current.create_remote('upstream', 'url')

      # When
      actual = current.get_config('remote.upstream.fetch')

      # Then
      expect(actual).to_not eq nil
    end
  end

  describe 'set_current_remote' do
    it 'should return false if the specified remote does not exist' do
      # Given
      create_repository

      # When
      actual = current.set_current_remote('foo')

      # Then
      expect(actual).to eq false
    end

    it 'should return false if not specified branch does not exist' do
      # Given
      create_repository
      current.create_remote('upstream', 'url')

      # When
      actual = current.set_current_remote('upstream', 'develop')

      # Then
      expect(actual).to eq false
    end

    it 'should return false if not currently in a branch' do
      # Given
      create_repository
      current.create_remote('upstream', 'url')

      # When
      actual = current.set_current_remote('upstream')

      # Then
      expect(actual).to eq false
    end

    it 'should set the current remote to the specified remote' do
      # Given
      create_repository
      create_branch('develop')
      current.create_remote('upstream', 'url')

      # When
      current.set_current_remote('upstream')
      actual = current.current_remote

      # Then
      expect(actual).to eq 'upstream'
    end

    it 'should return false if the remote is already the current one' do
      # Given
      create_repository
      create_branch('develop')
      current.create_remote('upstream', 'url')

      # When
      current.set_current_remote('upstream')
      actual = current.set_current_remote('upstream')

      # Then
      expect(actual).to eq false
    end
  end

  describe 'remote_url' do
    it 'should return the url of the specified remote' do
      # Given
      create_repository
      current.create_remote('foo', 'url')

      # When
      actual = current.remote_url('foo')

      # Then
      expect(actual).to eq 'url'
    end

    it 'should return false if the remote does not exist ' do
      # Given
      create_repository

      # When
      actual = current.remote_url('foo')

      # Then
      expect(actual).to eq false
    end

    it 'should return the url of the current remote if none specified' do
    end
  end

  describe 'set_remote_url' do
    it 'should change the url of the specified remote' do
      # Given
      create_repository
      current.create_remote('upstream', 'foo')

      # When
      current.set_remote_url('upstream', 'bar')
      actual = current.remote_url('upstream')

      # Then
      expect(actual).to eq 'bar'
    end

    it 'should return false if no such remote' do
      # Given
      create_repository
      current.create_remote('upstream', 'foo')

      # When
      actual = current.set_remote_url('foobar', 'bar')

      # Then
      expect(actual).to eq false
    end

    it 'should set the fetch as well as the url for origin' do
      # Given
      create_repository
      current.create_remote('origin', 'foo')
      current.set_remote_url('origin', 'bar')

      # When
      actual = current.get_config('remote.origin.fetch')

      # Then
      expect(actual).to_not eq nil
    end
  end

  describe '.expand_short_github_url' do
    subject { current.expand_short_github_url(input) }
    let(:input) { 'username/reponame' }
    it { should eq 'git@github.com:username/reponame.git' }
  end

  describe '.extract_github_url' do
    subject { current.extract_github_url(input) }
    let(:input) { 'git@github.com:username/reponame.git' }
    it { should include(user: 'username') }
    it { should include(repo: 'reponame') }
  end
end
# rubocop:enable Metrics/BlockLength
