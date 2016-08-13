require 'English'
require 'awesome_print'
require 'curb'
require 'nokogiri'

# Download subtitles from sous-titres.eu
# Usage:
#   $ subtitle-download "game of thrones" 6 1
#   $ subtitle-download "snatch"
class SubtitleDownload
  def initialize(*args)
    @is_movie = args.length == 1
    @is_serie = args.length > 1
    @name = args[0]

    if @is_serie
      @host = 'https://www.sous-titres.eu/series/'
      @season = args[1].to_i
      @episode = args[2].to_i
    end

    @host = 'https://www.sous-titres.eu/movies/' if @is_movie
  end

  def page_url
    url = @host
    url += @name.tr(' ', '_').downcase
    url += '.html'
    url
  end

  def page_available?(url)
    `wget --spider -q '#{url}'`
    $CHILD_STATUS.success?
  end

  def link(url)
    body = Curl.get(url).body_str
    doc = Nokogiri::HTML(body)
    tags = doc.css('a.subList')

    tags.each do |tag|
      lang = tag.css('span.lang img')[0]['title']
      next if lang != 'fr'

      season, episode = tag.css('.episodenum').text.split('×')
      next if season.to_i != @season
      next if episode.to_i != @episode

      return "#{@host}#{tag['href']}"
    end
    nil
  end

  def run
    url = page_url

    unless page_available?(url)
      puts "Unable to access #{url}"
      exit 1
    end

    download_link = link(url)
    if download_link.nil?
      puts 'No subtitle found'
      exit 1
    end

    `wget -c '#{download_link}'`
  end
end
