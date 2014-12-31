# encoding : UTF-8
require_relative "metadata-engine"
require "fileutils"

# Will create a .tracklist file containing metadata information about the 
# current album.
# This file will then be used by `mmu` to update file id3 tags. The initial 
# tracklist file is generated with data guessed from the filepath.
# Usage :
#  $ mktl ./file.mp3
#  $ mktl ./dir
#  $ mktl ./dir ./file.mp3 ./otherpath
# Options :
#  -f, --force : Overwrite existing .tracklist file if found

class GenerateTracklist
  # Custom exceptions
  class Error < StandardError; end
  class ArgumentError < Error; end

  def initialize(*args)
    parse_args(*args)
  end

  def parse_args(*args)
    @force = false
    if args.include?("-f")
      @force = true
      args.delete('-f')
    end
    args = [File.expand_path('.')] if args.size == 0

    @files = []
    args.each do |arg|
      # Skipping non-existing files
      next unless File.exists?(arg)

      # Keeping directory, not files
      dir = File.directory?(arg) ? arg : File.dirname(arg)
      dir = File.expand_path(dir)
      # Use CD subfolders if found
      cd_subfolders = Dir.glob(File.join(dir, 'CD*'))
      if cd_subfolders.size > 0
        @files += cd_subfolders
      else
        @files << dir
      end
    end
  end

  # Generate tracklist file
  def generate_tracklist(filepath)
    metadata = MetadataEngine.new(filepath)
    
    # Skip if already has a tracklist
    return if metadata.has_tracklist? && !@force

    # Do not create a tracklist for misc/ folder, it won't work
    if metadata.filepath.get_type == "misc"
      puts "Do not generate a .tracklist file for misc files. It won't work."
      puts "Just `mmu` the desired files and metadata will be extracted from the filepath"
      return
    end

    # begin
      File.open(metadata.tracklist.tracklist_filepath, 'w') do |tracklist|
        tracklist.write(metadata.tracklist.generate_content)
      end
      puts ".tracklist file created."
    # rescue
    #   puts "Unable to create .tracklist file!"
    #   FileUtils.rm(metadata.tracklist.tracklist_filepath)
    # end
  end

  # Create tracklist files for every arguments
  def run
    @files.each do |file|
      generate_tracklist(file)
    end
  end

end

