# encoding : utf-8
require 'open-uri'
require "fileutils"
require "shellwords"
require 'nokogiri'
# Base class for downloading a list of podcasts based on a RSS XML

class PodcastDownloader
  # Custom exceptions
  class Error < StandardError; end
  class ArgumentError < Error; end
  class DirNotFoundError < Error; end
  class NoListUrlError < Error; end

  def initialize(*args)
    parse_args(*args)
    @download_delay = 24*60*60
    @xml_file = File.join(@podcasts_dir, 'list.xml')

    # Allow child classes to define the xml location
    @list_url = ''
    pre_run

    if @list_url == ''
      raise PodcastDownloader::NoListUrlError, "No url specified for the podcast list", ""
    end
  end

  # Must pass the directory where the podcasts are saved
  def parse_args(*args)
    unless args.size > 0
      raise PodcastDownloader::ArgumentError, "You need to pass at least the dir holding the podcasts", ""
    end

    @podcasts_dir = File.expand_path(args[0])
    unless File.directory?(@podcasts_dir)
      raise PodcastDownloader::DirNotFoundError,  "Unable to find #{@podcasts_dir}", ""
    end
  end

  # Must be redefined in child class with specific values
  def pre_run
    puts "You must define a `pre_run` method in your child class where you define `@list_url` to the RSS XML url"
  end

  # Return the path of the podcasts.xml file
  def update_xml_list
    # No file, we download it
    unless File.exists?(@xml_file) 
      download_xml_list()
    end

    # File still young enough, we keep it
    if (Time.now() - File.mtime(@xml_file)).to_i < @download_delay
      puts "Podcast list is up to date"
      return
    end

    # We download a new file
    download_xml_list()
  end

  # Download xml file
  def download_xml_list
    puts "Downloading #{File.basename(@xml_file)}"
    File.open(@xml_file, "w") do |xml_file|
      open(@list_url, 'r') do |url_file|
        xml_file.write(url_file.read)
      end
    end
  end

  # Parse the xml file and return an array of all episodes
  def parse_podcasts_xml
    doc = Nokogiri::XML(File.new(@xml_file))
    list = Hash.new

    for node in doc.root.xpath("//item")
      hash = node_to_hash(node)

      # Fixing some common issues with hashes
      hash['index'] = hash['index'].to_s
      hash['title'] = hash['title'].gsub('/', '-').gsub(':',' -').gsub('  ', ' ')
      hash['year'] = hash['date'].year.to_s

      # Saving it to the list
      list[hash['index']] = hash
    end

    return list
  end

  # FAT32 has a list of illegal characters, we strip those from the
  # filepath because music-metadata-update will strip them anyway.
  def make_fat32_compliant(filepath)
    extname = File.extname(filepath)
    basename = File.basename(filepath, extname)
    dirname = File.dirname(filepath)
    path_without_ext = File.join(dirname, basename)

    split = path_without_ext.split("/")
    new_split = []
    split.map do |part|
      new_split << part.gsub(/([\?\*\|:;"“”<>])/, "").strip.gsub(/ {2,}/," ").gsub('’', "'")
    end
    return new_split.join("/")+extname
  end


  # Must be overriden in child classes to transforme a node to a hash
  def node_to_hash(node)
    puts "You must define a `node_to_hash` method in your child class to parse the Nokogiri nodes"
  end

  # Update the tracklist by adding a new element to it
  def update_tracklist(filepath, index, title)
    # Stop if no tracklist
    dirname = File.dirname(filepath)
    tracklist_file = File.join(dirname, ".tracklist")
    return unless File.exists?(tracklist_file)

    # Split tracklist into header and content
    content = File.read(tracklist_file).split("\n")
    header = []
    tracks = []
    blank_line_found = false
    track_found = false
    content.each do |line|
      # Tracks
      if blank_line_found == true
        # Update the line with the new one if same index
        track_index, = line.split(" - ")
        if track_index == index
          line =  "#{index} - #{title}" 
          track_found = true
        end

        # Adding the line to the list
        tracks << line
        next
      else
        # Delimiter between header and tracks
        if line == ''
          blank_line_found = true
          next
        end
        # Header
        header << line
      end
    end

    # Adding the new track to the list if not already in the list
    tracks << "#{index} - #{title}" unless track_found == true 

    # Reordering the tracks
    tracks.sort!

    # Getting the new content in the file
    content = []
    content += header
    content << ""
    content += tracks
    File.open(tracklist_file, "w") do |file|
      file.write(content.join("\n"))
    end

    puts ".tracklist file updated"

  end


  def run
    # Update the list
    update_xml_list

    # Check that we have every available podcast, and download them if not
    new_files = []
    parse_podcasts_xml.each do |index, podcast|
      # Create a dir for each year
      year_dir = File.join(@podcasts_dir, podcast['year'])
      FileUtils.mkdir_p(year_dir)

      # We get the length of the prefix id based on other files in the dir
      mp3_in_year_dir = Dir[File.join(year_dir, '*.mp3')].sort
      if (mp3_in_year_dir.size > 0) 
        id_length = [File.basename(mp3_in_year_dir.last).split(" - ")[0].size, 2].max
      else
        id_length = 2
      end

      prefix = "%0#{id_length}d" % podcast['index']

      basename = "#{prefix} - #{podcast['title']}.mp3"
      filepath = make_fat32_compliant(File.join(year_dir, basename))

      next if File.exists?(filepath)

      # Downloading the missing podcasts
      puts "Downloading \"#{basename}\""
      wget_options = [
        'wget',
        '--continue',
        '--timestamping=off',
        '--server-response=off',
        '--verbose',
        podcast['url'].shellescape,
        "-O #{filepath.shellescape}"
      ]
      %x[#{wget_options.join(' ')}]

      # Update tracklist
      update_tracklist(filepath, prefix, podcast['title'])

      # Keep track of the newly added file
      new_files << filepath

    end

    # Updating the files metadata
    new_files.map do |file|
      file.shellescape
    end
    puts %x[music-metadata-update #{new_files.join(' ')}]


  end
end
