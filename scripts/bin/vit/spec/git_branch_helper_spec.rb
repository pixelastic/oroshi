require 'spec_helper'

describe(GitBranchHelper) do
  let(:test_instance) { Class.new { include GitHelper }.new }

  after(:each) do |example|
    delete_directory(example)
  end

  describe 'branch?' do
    it 'returns true if the branch exists' do
      # Given
      create_repository
      create_branch 'foo'

      # When
      actual = test_instance.branch? 'foo'

      # Then
      expect(actual).to eq true
    end

    it 'returns false if the branch does not exist' do
      # Given
      create_repository

      # When
      actual = test_instance.branch? 'do_not_exist'

      # Then
      expect(actual).to eq false
    end

    it 'returns false if only partial match' do
      # Given
      create_repository
      create_branch 'foobar'

      # When
      actual = test_instance.branch? 'foo'

      # Then
      expect(actual).to eq false
    end
  end

  describe 'current_branch' do
    it 'returns the name of the current branch' do
      # Given
      create_repository
      create_branch 'foo'

      # When
      actual = test_instance.current_branch

      # Then
      expect(actual).to eq 'foo'
    end

    it 'returns HEAD if no current branch' do
      # Given
      create_repository

      # When
      actual = test_instance.current_branch

      # Then
      expect(actual).to eq 'HEAD'
    end
  end

  describe 'create_branch' do
    it 'should create a new branch' do
      # Given
      create_repository
      # Note: A branch can only be seen once at least one commit exists
      add_commit

      # When
      test_instance.create_branch('develop')

      # Then
      expect(test_instance.branch?('develop')).to eq true
    end

    it 'should return false when creating a branch that already exists' do
      # Given
      create_repository
      create_branch('develop')

      # When
      actual = test_instance.create_branch('develop')

      # Then
      expect(actual).to eq false
    end
  end

  fdescribe 'parse_raw_branch' do
    items = [
      {
        input: '  master abcdef01 feat(stuff): Add stuff',
        expected: {
          is_current: false,
          hash: 'abcdef01',
          message: 'feat(stuff): Add stuff',
          name: 'master',
          remote_branch_name: 'master',
          remote_ahead: nil,
          remote_behind: nil,
          remote_is_gone: false,
          remote_name: 'origin'
        }
      },
      {
        input: '* master abcdef01 feat(stuff): Add stuff',
        expected: {
          is_current: true
        }
      },
      {
        input: '* foo        abcdef01 some stuff',
        expected: {
          hash: 'abcdef01',
          name: 'foo'
        }
      },
      {
        input: '  master 0e87d60 [origin/master] v2.10.0',
        expected: {
          message: 'v2.10.0',
          remote_name: 'origin',
          remote_branch_name: 'master',
          remote_ahead: nil,
          remote_behind: nil,
          remote_is_gone: false
        }
      },
      {
        input:
          '  master 0e87d60 [origin/master: ahead 2] feat(stuff): Add stuff',
        expected: {
          remote_name: 'origin',
          remote_branch_name: 'master',
          remote_ahead: '2',
          remote_behind: nil,
          remote_is_gone: false
        }
      },
      {
        input: '* new-branch 0e87d60 [origin/new-branch: gone] v2.10.0',
        expected: {
          remote_name: 'origin',
          remote_branch_name: 'new-branch',
          remote_ahead: nil,
          remote_behind: nil,
          remote_is_gone: true
        }
      },
      {
        input: '* (HEAD detached at 0e87d60) 0e87d60 v2.10.0',
        expected: {
          hash: '0e87d60',
          message: 'v2.10.0',
          name: 'HEAD'
        }
      },
      {
        input: '* master     88f671d [ahead 1, behind 5] fix(jest): Remove stuff',
        expected: {
          hash: '88f671d',
          remote_ahead: '1',
          remote_behind: '5',
          remote_name: 'origin',
          remote_branch_name: 'master'
        }
      }

    ]
    items.each do |item|
      it item[:input] do
        actual = test_instance.parse_raw_branch(item[:input])
        expected = item[:expected]

        expected.each do |key, value|
          expect(actual[key]).to(
            eq(value),
            "#{key}:\nActual:     #{actual[key]}\nExpected:   #{value}"
          )
        end
      end
    end

    # items.each do |item|
    #   describe item[:input] do
    #     expected = item[:expected]

    #     expected.each do |key, value|
    #       it "#{key}" do
    #         p key
    #         p value

    #       end
    #       # expect(actual[key]).to(
    #       #   eq(value),
    #       #   "#{key}:\nActual:     #{actual[key]}\nExpected:   #{value}"
    #       # )
    #     end
    #   end
    # end
  end
end
