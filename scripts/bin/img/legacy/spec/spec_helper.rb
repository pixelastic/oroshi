require 'awesome_print'
require 'fileutils'
require './lib/image_helper.rb'

RSpec.configure do |config|
  config.filter_run(focus: true)
  config.fail_fast = true
  config.run_all_when_everything_filtered = true

  config.after(:each) do |example|
    # Delete temp dir if no error
    FileUtils.remove_dir(@tmp_path) if !@tmp_path.nil? && !example.exception
  end
end

# Return the path to the original fixture file
def fixture(path)
  File.expand_path("./spec/fixtures/#{path}")
end

# Copy the fixture to a temp directory before acting on it
def copy(original)
  init_tmp_directory if @tmp_path.nil?

  new_path = File.join(@tmp_path, File.basename(original))
  FileUtils.cp(original, new_path)
  new_path
end

# Init a temporary directory where to operate on the files
def init_tmp_directory
  now = [
    Time.now.strftime('%Y-%m-%d_%H-%M-%S'),
    Time.now.to_f.to_s.tr('.', '')
  ].join('_')
  @tmp_path = File.join(Dir.tmpdir, 'img/spec', "tmp_#{now}")
  FileUtils.mkdir_p(@tmp_path)
end
