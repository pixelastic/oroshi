# rubocop:disable Metrics/BlockLength
require 'spec_helper'

describe(GitArgumentHelper) do
  let(:current) { Class.new { include GitHelper }.new }

  after(:each) do |example|
    delete_directory(example)
  end

  describe 'path?' do
    it 'should return true if looks like a filepath' do
      # Given

      # When
      actual = current.path?('./somewhere')

      # Then
      expect(actual).to eq true
    end
  end

  describe 'url?' do
    it 'should return true for github-like urls' do
      # Given

      # When
      actual = current.url?('git@github.com:pixelastic/vit.git')

      # Then
      expect(actual).to eq true
    end
  end

  describe '.github_short_url?' do
    subject { current.github_short_url?(input) }

    context 'with a real github url' do
      let(:input) { 'username/reponame' }
      it { should eq true }
    end
    context 'with a non-github url' do
      let(:input) { 'something:something.git' }
      it { should eq false }
    end
  end

  describe 'argument?' do
    it 'should catch single dash arguments' do
      # Given

      # When
      actual = current.argument?('-n')

      # Then
      expect(actual).to eq true
    end

    it 'should catch double dash arguments' do
      # Given

      # When
      actual = current.argument?('--bitbucket')

      # Then
      expect(actual).to eq true
    end
  end

  describe 'guess_elements' do
    it 'should guess the branch' do
      # Given
      create_repository
      create_branch 'develop'
      input = ['develop']

      # When
      actual = current.guess_elements(input)

      # Then
      expect(actual[:branch]).to eq 'develop'
    end

    it 'should guess the tag' do
      # Given
      create_repository
      create_tag 'v1'
      input = ['v1']

      # When
      actual = current.guess_elements(input)

      # Then
      expect(actual[:tag]).to eq 'v1'
    end

    it 'should guess the remote' do
      # Given
      create_repository
      create_remote('foo')
      input = ['foo']

      # When
      actual = current.guess_elements(input)

      # Then
      expect(actual[:remote]).to eq 'foo'
    end

    it 'should guess the url' do
      # Given
      input = ['foo@bar:baz.git']

      # When
      actual = current.guess_elements(input)

      # Then
      expect(actual[:url]).to eq 'foo@bar:baz.git'
    end

    it 'should guess an obvious path' do
      # Given
      input = ['./path']

      # When
      actual = current.guess_elements(input)

      # Then
      expect(actual[:path]).to eq './path'
    end

    it 'should guess arguments' do
      # Given
      input = ['-n', '--bitbucket']

      # When
      actual = current.guess_elements(input)

      # Then
      expect(actual[:arguments]).to include('-n')
      expect(actual[:arguments]).to include('--bitbucket')
    end

    it 'should guess all the branch/tag/remote' do
      # Given
      create_repository
      create_branch_with_remote('develop', 'upstream')
      create_tag 'v1'
      input = %w[develop v1 upstream]

      # When
      actual = current.guess_elements(input)

      # Then
      expect(actual[:branch]).to eq 'develop'
      expect(actual[:tag]).to eq 'v1'
      expect(actual[:remote]).to eq 'upstream'
    end

    it 'should accept either an array or splats' do
      # Given
      create_repository
      create_branch_with_remote('develop', 'upstream')
      create_tag 'v1'
      input = %w[develop v1 upstream]

      # When
      actual = current.guess_elements(*input)

      # Then
      expect(actual[:branch]).to eq 'develop'
      expect(actual[:tag]).to eq 'v1'
      expect(actual[:remote]).to eq 'upstream'
    end

    it 'should default to current branch' do
      # Given
      create_repository
      create_branch('develop')
      input = []

      # When
      actual = current.guess_elements(input)

      # Then
      expect(actual[:branch]).to eq 'develop'
    end

    it 'should default to current tag' do
      # Given
      create_repository
      create_tag('v1')
      input = []

      # When
      actual = current.guess_elements(input)

      # Then
      expect(actual[:tag]).to eq 'v1'
    end

    it 'should default to current remote' do
      # Given
      create_repository
      input = []

      # When
      actual = current.guess_elements(input)

      # Then
      expect(actual[:remote]).to eq 'origin'
    end

    it 'should put all unknown in a special attribute' do
      # Given
      create_repository
      input = %w[foo bar]

      # When
      actual = current.guess_elements(input)

      # Then
      expect(actual[:unknown]).to eq %w[foo bar]
    end

    it 'should guess path and url' do
      # Given
      input1 = ['./path', 'foo@bar:baz.git']
      input2 = ['foo@bar:baz.git', './path']

      # When
      actual1 = current.guess_elements(input1)
      actual2 = current.guess_elements(input2)

      # Then
      expect(actual1).to eq actual2
    end
  end
end
# rubocop:enable Metrics/BlockLength
