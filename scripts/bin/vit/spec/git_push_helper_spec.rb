require 'spec_helper'

describe(GitPushHelper) do
  let(:test_instance) { Class.new { include GitHelper }.new }

  after(:each) do |example|
    delete_directory(example)
  end
end
